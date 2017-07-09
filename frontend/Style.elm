module Style exposing (..)

import Css exposing (..)
import Css.Elements exposing (button, html, body, a)
import Css.Namespace exposing (namespace)


type CssClasses
    = Menu
    | NewBookmarkButton


type CssIds
    = App


css : Stylesheet
css =
    (stylesheet << namespace "bookie")
        [ html
            [ fontFamily sansSerif
            ]
        , body
            [ backgroundColor primaryBackgroundColor
            , color primaryTextColor
            , height <| pct 100
            , margin2 zero auto
            , marginTop <| px 24
            , marginBottom <| px 24
            , width <| pct 95
            , maxWidth <| px 960
            ]
        , a
            [ color primaryAccentColor
            ]
        , button
            [ cursor pointer
            ]
        , id App
            []
        , class Menu
            [ displayFlex
            , justifyContent spaceBetween
            ]
        , class NewBookmarkButton
            [ backgroundColor successColor
            , color whiteColor
            , border3 (px 1) solid mediumGray
            , borderRadius <| px 3
            , padding <| px 4
            , margin <| px 4
            , hover
                [ backgroundColor successSaturatedColor
                ]
            ]
        ]



------------
-- Colors --
------------


primaryTextColor : Css.Color
primaryTextColor =
    Css.hex "333"


{-| Deep sky blue
-}
primaryAccentColor : Css.Color
primaryAccentColor =
    Css.hex "428bca"


{-| Caramel
-}
secondaryAccentColor : Css.Color
secondaryAccentColor =
    Css.hex "ca8142"


successColor : Css.Color
successColor =
    Css.hex "5cb85c"


warningColor : Css.Color
warningColor =
    Css.hex "ec971f"


dangerColor : Css.Color
dangerColor =
    Css.hex "d9534f"


successSaturatedColor : Css.Color
successSaturatedColor =
    Css.hex "50c850"


warningSaturatedColor : Css.Color
warningSaturatedColor =
    Css.hex "ff9d0a"


dangerSaturatedColor : Css.Color
dangerSaturatedColor =
    Css.hex "ea3e3e"


mediumGray : Css.Color
mediumGray =
    Css.hex "c0c0c0"


lightGray : Css.Color
lightGray =
    Css.hex "f0f0f0"


whiteColor : Css.Color
whiteColor =
    Css.hex "fff"


primaryBackgroundColor : Css.Color
primaryBackgroundColor =
    Css.hex "f9f9f9"


secondaryBackgroundColor : Css.Color
secondaryBackgroundColor =
    Css.hex "e0e0e0"
