module Browser.Style exposing (..)

import Css exposing (..)
import Css.Colors as Colors
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
    | HeaderLeft
    | HeaderRight
    | Sorted
    | Sortable


type CssIds
    = Browser


css : Stylesheet
css =
    (stylesheet << namespace "bookie")
        [ id Browser
            [ border3 (px 1) solid Base.lightGray
            , height <| pct 75
            , borderRadius <| px 6
            , marginTop <| px 8
            , paddingTop <| px 2
            ]
        , ul
            [ listStyle none
            , overflowY auto
            , height <| pct 100
            , margin zero
            , paddingLeft <| px 32
            , paddingRight <| px 2
            ]
        , li
            [ displayFlex
            , position relative
            , children
                [ div
                    [ padding <| px 2
                    , border3 (px 1) solid Base.mediumGray
                    ]
                ]
            , nthChild "2n+2"
                [ children
                    [ div
                        [ borderTop zero
                        , borderBottom zero
                        ]
                    ]
                ]
            , lastChild
                [ children
                    [ div
                        [ borderBottom3 (px 1) solid Base.mediumGray
                        ]
                    ]
                ]
            ]
        , class Header
            [ displayFlex
            , justifyContent spaceBetween
            , backgroundColor Base.secondaryBackgroundColor
            , color Base.primaryTextColor
            , fontWeight <| int 600
            , padding <| px 4
            , hover
                [ descendants
                    [ class Sorted
                        [ opacity <| num 0.75
                        ]
                    ]
                ]
            ]
        , class HeaderLeft
            [ borderTopLeftRadius <| px 6
            ]
        , class HeaderRight
            [ borderTopRightRadius <| px 6
            ]
        , class Title
            [ width <| pct 25
            ]
        , class Url
            [ width <| pct 40
            , borderLeft zero
            , borderRight zero
            ]
        , class Description
            [ width <| pct 35
            ]
        , class Selector
            [ cursor pointer
            , height <| px 8
            , width <| px 24
            , left <| px -30
            , top <| px 6
            , position absolute
            , backgroundColor Colors.black
            , opacity <| num 0.15
            , border <| px 1
            , before
                [ property "content" "\"edit\""
                , position relative
                , top <| px -6
                , color Base.lightGray
                ]
            , hover
                [ opacity <| num 0.67
                ]
            ]
        , class RowSelected
            [ backgroundColor Base.lightGray
            ]
        , class Sortable
            [ cursor pointer
            , hover
                [ backgroundColor Base.mediumGray
                ]
            ]
        , class Sorted
            [ opacity <| num 0.5
            ]
        ]
