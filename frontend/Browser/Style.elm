module Browser.Style exposing (..)

import Css exposing (..)
import Css.Elements exposing (div, li, ul)
import Css.Namespace exposing (namespace)
import Style as Base


type CssClasses
    = Header
    | Url
    | Title
    | Description
    | Selector
    | None
    | RowSelected


type CssIds
    = Browser


css : Stylesheet
css =
    (stylesheet << namespace "bookie")
        [ id Browser
            []
        , ul
            [ listStyle none
            ]
        , li
            [ displayFlex
            , position relative
            , children
                [ div
                    [ padding <| px 2
                    , borderStyle solid
                    ]
                ]
            ]
        , class Header
            [ backgroundColor <| hex "444"
            , fontWeight <| int 300
            , padding <| px 2
            ]
        , class Title
            [ width <| pct 25
            , borderWidth <| px 1
            ]
        , class Url
            [ width <| pct 40
            , border <| px 1
            , borderColor <| hex "000"
            ]
        , class Description
            [ width <| pct 35
            , borderWidth <| px 1
            ]
        , class Selector
            [ color Base.primaryAccentColor
            ]
        , class RowSelected
            [ backgroundColor <| rgba 50 100 150 0.25 ]
        ]
