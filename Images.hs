module Images(getImages) where

import Types
import Text.HTML.TagSoup(parseTags, Tag(..), (~==))
import System.FilePath(takeExtension)
import Data.List(nub, find)
import Test.HUnit

getImages :: PageContents -> [RelativeUrl]
getImages = getUrls . filterImages . parseTags
    where 
        getUrls = map getUrl
        getUrl (TagOpen tag pairs) = extractImgSrcUrl pairs
            where 
                extractImgSrcUrl = snd . justValue . findSrcPair
                findSrcPair = find (\(name, url) -> name == "src")
                justValue (Just x) = x

filterImages ::  [Tag String] -> [Tag String]
filterImages = filter (~== "<img src>") 


-- ===================
-- Tests
-- ===================

tests = TestList $ map TestCase
    [ assertEqual "extracting images when one is contained"
        (getImages pageContentsWithOneImage)    ["/support/figs/tip.png"]
    , assertEqual "extracting images when two are contained"
        (getImages pageContentsWithTwoImages)   ["/support/figs/tip.png", 
                                                 "/support/figs/other.png"]
    , assertEqual "extracting images when none is contained"
        (getImages pageContentsWithoutImage)    [] 
    ]
    where 
        pageContentsWithOneImage  ="<img alt=\"[Tip]\" src=\"/support/figs/tip.png\">"
        pageContentsWithTwoImages = "<img alt=\"[Tip]\" src=\"/support/figs/tip.png\">" ++
                                    "<img alt=\"[Oth]\" src=\"/support/figs/other.png\">" 
        pageContentsWithoutImage  ="<span>see no image</span>"


runTests = do
    runTestTT tests
