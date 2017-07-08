module Style exposing (..)

import Css exposing (..)
import Css.Elements exposing (html, body, a)
import Css.Namespace exposing (namespace)


type CssClasses
    = Menu


type CssIds
    = App


css : Stylesheet
css =
    (stylesheet << namespace "bookie")
        [ html
            []
        , body
            [ backgroundColor primaryBackgroundColor
            , color primaryTextColor
            , height <| pct 100
            , margin2 zero auto
            , marginTop <| px 24
            , marginBottom <| px 24
            , width <| pct 95
            ]
        , a
            [ color primaryAccentColor
            ]
        , id App
            []
        , Css.class Menu
            []
        ]


primaryTextColor : Css.Color
primaryTextColor =
    Css.hex "ddd"


primaryAccentColor : Css.Color
primaryAccentColor =
    Css.hex "b5ddd1"


primaryBackgroundColor : Css.Color
primaryBackgroundColor =
    Css.hex "111"
