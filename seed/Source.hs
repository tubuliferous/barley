module Source where

import Control.Monad (when)
import Control.Monad.IO.Class
import qualified Data.ByteString.Char8 as C
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import Snap.Types
import qualified Snap.Types as Snap
import System.Directory
import System.FilePath ((</>), dropExtension)
import System.Time (ClockTime, getClockTime)
import Text.Html hiding ((</>))
import qualified Text.Html as Html

nu = () -- DO NOT DELETE THIS

handler :: Snap ()
handler = do
    meth <- rqMethod `fmap` getRequest
    when (meth == POST) handleSave
    file <- getParam (C.pack "file")
    html <- liftIO . mkSrcPage $ maybe "<rename me>" C.unpack file
    modifyResponse $ setContentType (C.pack "text/html; charset=UTF-8")
    writeBS $ (T.encodeUtf8 . T.pack) $ renderHtml html

handleSave :: Snap()
handleSave = do
    file <- getParam (C.pack "file")
    contents <- getParam (C.pack "contents")
    save file contents
  where
    save (Just f) (Just c) = liftIO $ writeFile (C.unpack f) (C.unpack c)
    save _ _ = modifyResponse $ setResponseCode 400
    
data SrcInfo = SrcInfo { siPath :: FilePath
                       , siFullPath :: FilePath
                       , siExists :: Bool
                       , siWritable :: Bool
                       , siModTime :: ClockTime
                       , siContents :: String
                       }

srcInfo :: FilePath -> IO SrcInfo
srcInfo path = do
    cwd <- getCurrentDirectory
    let fullPath = cwd </> path
    exists <- doesFileExist path
    canWrite <- if exists then writable `fmap` getPermissions path else return False
    modTime <- if exists then getModificationTime path else getClockTime
    contents <- if exists then readFile fullPath else return (emptyModule path)
        -- maybe these should all be Maybe
    return SrcInfo { siPath = path
                   , siFullPath = fullPath
                   , siExists = exists
                   , siWritable = canWrite
                   , siModTime = modTime
                   , siContents = contents
                   }

mkSrcPage :: FilePath -> IO Html
mkSrcPage path = srcInfo path >>= return . srcPage


srcPage :: SrcInfo -> Html
srcPage si =
  thehtml << [
    header << [
      thelink ! [href "static/scaffold.css", rel "stylesheet",
                   thetype "text/css"] << noHtml,
      thetitle << ("Source of " ++ siPath si)
      ],
    body << [
      thediv ! [identifier "content", theclass "with-sidebar"] << [
        h1 << siPath si,
        p << small << siFullPath si,
        form ! [Html.method "POST", identifier "editor"] <<
          [ input ! [thetype "button", value "Edit", identifier "btn-edit"],
            textarea ! [theclass "src", name "contents", identifier "txt-src",
                strAttr "readonly" "readonly" ] << siContents si
          , input ! [thetype "button", value "Cancel", identifier "btn-cancel",
                strAttr "disabled" "disabled"]
          , input ! [thetype "submit", value "Save", identifier "btn-save",
                strAttr "disabled" "disabled"]
          ],
        sidebar si,
        jQuery,
        scripts
        ]
      ]
    ]


sidebar :: SrcInfo -> Html
sidebar si = thediv ! [identifier "sidebar"] <<
    map (thediv ! [theclass "module"]) [ modFStat si, modActions si, modSearch]

modFStat :: SrcInfo -> Html
modFStat si = (h2 << "File Info") +++
    if siExists si
        then [if siWritable si then noHtml else p << bold << "read only",
              p << show (siModTime si)]
        else [p << bold << "new file"]

modActions :: SrcInfo -> Html
modActions si = (h2 << "Actions") +++
    unordList [ anchor ! [href (dropExtension $ siPath si), target "barley-run",
                    title "Run this code by browsing its page in another window"]
                    << "Run"
              , italics << "Revert"
              ] +++
    unordList [ anchor ! [href ("file://" ++ siFullPath si),
                    title "Provides a file:// scheme URL to the local file"]
                    << "Local File"
              , anchor ! [href (siPath si)] << "Download"
              ]

modSearch :: Html
modSearch = (h2 << "Research") +++
    [ form ! [action "http://holumbus.fh-wedel.de/hayoo/hayoo.html"
                , target "barley-reseach"] <<
        [ input ! [thetype "text", name "query"]
        , input ! [thetype "submit", value "Hayoo"]
        ]
    , form ! [action "http://haskell.org/hoogle", target "barley-reseach"] <<
        [ input ! [thetype "text", name "q"] 
        , input ! [thetype "submit",  value "Hoogle"]
        ]
    ]
              
emptyModule :: FilePath -> String
emptyModule filename = 
    "module " ++ modName ++ " where\n\
    \\n\
    \import Text.Html\n\
    \\n\
    \page = body << [\n\
    \    h1 << \"Hi!\",\n\
    \    paragraph << \"testing\"\n\
    \    ]\n"
 where
   modName = filename  -- TODO should replace slashes with dots

jQuery :: Html
jQuery = toHtml $ map script ["static/jquery.js", "static/jquery.elastic.js"]
  where
    script s = tag "script" ! [ thetype "text/javascript", src s ] << noHtml

scripts :: Html
scripts = tag "script" ! [ thetype "text/javascript"] <<
    [ "bEnable = function(i) {\
            \$(i).removeAttr('disabled').animate({opacity: 1.0}, 'fast');\
        \};\n"
    , "bDisable = function(i) {\
            \$(i).attr('disabled', 'disabled').animate({opacity: 0.2}, 'fast');\
        \}\n"
    , "mkEditable = function() {\
            \$('#txt-src').removeAttr('readonly');\
            \bDisable('#btn-edit');\
            \bEnable('#btn-cancel');\
            \bEnable('#btn-save');\
        \};\n"
    , "mkReadOnly = function() {\
            \$('#txt-src').attr('readonly', 'readonly');\
            \bEnable('#btn-edit');\
            \bDisable('#btn-cancel');\
            \bDisable('#btn-save');\
        \};\n"
    , "$('#txt-src').elastic();\n"
    , "$('#btn-edit').click(mkEditable);\n"
    , "$('#btn-cancel').click(mkReadOnly);\n"
    , "mkReadOnly();\n"
    ]

