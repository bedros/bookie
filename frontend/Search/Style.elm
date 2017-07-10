module Search.Style exposing (..)

import Css exposing (..)
import Css.Elements exposing (button, input, div, li, ul)
import Css.Namespace exposing (namespace)
import Style as Base


type CssClasses
    = SearchBox


type CssIds
    = Search


css : Stylesheet
css =
    (stylesheet << namespace "bookie")
        [ id Search
            [ children
                [ input
                    [ border3 (px 1) solid Base.mediumGray
                    , borderRadius <| px 3
                    , padding <| px 4
                    , margin <| px 4
                    , width <| px 256
                    ]
                ]
            ]
        , class SearchBox
            []
        ]
