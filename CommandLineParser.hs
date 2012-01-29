module CommandLineParser(Args(..), legend, parseArgs) where

import Types

import System.Environment(getArgs)
import Test.HUnit

data Args  = Args   { title           :: Maybe String
                    , language        :: String
                    , author          :: Maybe String
                    , tocUrl          :: Maybe Url
                    , rootUrl         :: Maybe Url
                    } deriving (Show, Eq)

titleOpt    = "--title"
languageOpt = "--language"
authorOpt   = "--author"
tocOpt      = "--toc"
rootOpt     = "--root"

options = [ titleOpt, languageOpt, authorOpt, tocOpt, rootOpt ]

legend = 
     [ (titleOpt, normalizeOption titleOpt, "Book title (required)")
     , (languageOpt, normalizeOption languageOpt, "Language (default en-US)")
     , (authorOpt, normalizeOption authorOpt, "Book author")
     , (tocOpt, normalizeOption tocOpt, "Url to the page that contains the table of contents of the book")
     , (rootOpt, normalizeOption rootOpt, "Url that points to the root of the book (e.g, to resolve images)")
     ]

parseArgs :: [String] -> Args
parseArgs options = Args {
        title    = tryGetArg titleOpt,
        language = getArg languageOpt "en-us",
        author   = tryGetArg authorOpt,
        tocUrl   = tryGetArg tocOpt,
        rootUrl  = tryGetArg rootOpt
    }

    where 
        normOpts = normalizeOptions options
        tryGetArg option = (extractArg . dropWhile (/= option)) normOpts 
            where extractArg (x1:x2:xs) = Just x2
                  extractArg _          = Nothing

        getArg option alternative = 
            case tryGetArg option of
               Just arg -> arg
               Nothing  -> alternative

normalizeOptions :: [String] -> [String]
normalizeOptions = map normalizeOption

normalizeOption :: String -> String
normalizeOption "-t" = titleOpt
normalizeOption "-l" = languageOpt
normalizeOption "-a" = authorOpt
normalizeOption "-c" = tocOpt
normalizeOption "-r" = rootOpt
normalizeOption x    = x

-----------------------
-- ----  Tests  ---- --
-----------------------

normalizeOptionsTests =
    [ assertEqual "empty args" [] $ normalizeOptions [] 
    , assertEqual "no shortcuts" allVerbose $ normalizeOptions allVerbose 
    , assertEqual "title shortcut" ["--title", "some"] $ normalizeOptions ["-t", "some"] 
    , assertEqual "title and url shortcuts" 
        ["--title", "some", "--toc", "http"] $ normalizeOptions ["-t", "some", "-c", "http"] 
    , assertEqual "title and url shortcuts and verbose options" 
        ["--title", "some", "--author ", "verbose", "--toc", "http"] $ 
        normalizeOptions ["-t", "some", "--author ", "verbose", "-c", "http"] 
    ]
    where allVerbose = ["--title", "some", "--toc", "http"]

parseArgsTests =
    [ assertEqual "no args" 
        (Args Nothing defLang  Nothing  Nothing  Nothing) $ parseArgs []
    , assertEqual "title given"
        (Args (Just givenTitle) defLang  Nothing  Nothing  Nothing) $
        parseArgs ["--title", givenTitle]
    , assertEqual "title and author given"
        (Args (Just givenTitle) defLang  (Just givenAuthor)  Nothing  Nothing) $
        parseArgs ["--title", givenTitle, "-a", givenAuthor]
    , assertEqual "title, language and author given"
        (Args (Just givenTitle) givenLanguage (Just givenAuthor)  Nothing  Nothing) $
        parseArgs ["--title", givenTitle, "-a", givenAuthor, "-l", givenLanguage]
    ]

    where defLang = "en-us"
          givenTitle = "the title"
          givenAuthor = "the author"
          givenLanguage = "de-DE"

tests = TestList $ map TestCase $
    normalizeOptionsTests ++
    parseArgsTests 

runTests = do
    runTestTT tests