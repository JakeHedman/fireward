module OptionParser
  ( Options (..)
  , options
  , startOptions
  , getOptions
  ) where

import System.Console.GetOpt
  ( OptDescr (Option)
  , ArgOrder (RequireOrder)
  , ArgDescr (NoArg, ReqArg)
  , getOpt
  , usageInfo
  )

import Control.Monad (when)
import System.Environment (getArgs, getProgName)
import System.IO 
  ( IO(..)
  , readFile
  , writeFile
  , hPutStrLn
  , stderr
  , stdin
  , stdout
  )
import System.Exit (exitWith, ExitCode(..))
import Paths_fireward (version)
import Data.Version (showVersion)
import Data.List (intercalate)
import Data.Char (isSpace)

data Options = Options  { optVerbose    :: Bool
                        , optLang       :: String
                        , optInput      :: IO String
                        , optOutput     :: String -> IO ()
                        }

startOptions :: Options
startOptions = Options  { optVerbose    = False
                        , optLang       = "rules"
                        , optInput      = getContents
                        , optOutput     = putStr
                        }

options :: [ OptDescr (Options -> IO Options) ]
options =
    [ Option "i" ["input"]
        (ReqArg
            (\arg opt -> return opt { optInput = readFile arg })
            "FILE")
        "Input fireward file, instead of stdin"
 
    , Option "o" ["output"]
        (ReqArg
            (\arg opt -> return opt { optOutput = writeFile arg })
            "FILE")
        "Output file, instead of stdout"
 
    , Option "s" ["string"]
        (ReqArg
            (\arg opt -> return opt { optInput = return arg })
            "STRING")
        "Input string, instead of stdin or file"
    , Option "l" ["lang", "language"]
        (ReqArg
            (\arg opt -> return opt { optLang = arg })
            "language")
        "Output language. One of: rules, typescript (or ts)."
 
    , Option "V" ["version"]
        (NoArg
            (\_ -> do
                hPutStrLn stdout (showVersion version)
                exitWith ExitSuccess))
        "Print version"
 
    , Option "h" ["help"]
        (NoArg
            (\_ -> do
              prg <- getProgName
              hPutStrLn stderr (usageInfo prg options)
              exitWith ExitSuccess))
        "Show this help"
    ]

getOptions = do
    args <- getArgs
 
    -- Parse options, getting a list of option actions
    let (actions, nonOptions, errors) = getOpt RequireOrder options args
 
    -- Here we thread startOptions through all supplied option actions
    opts <- foldl (>>=) (return startOptions) actions
    return (opts, actions, nonOptions, errors)
 
