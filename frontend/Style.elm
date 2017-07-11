module Style exposing (..)

import Css exposing (..)
import Css.Colors as Colors
import Css.Elements exposing (div, button, html, body, a)
import Css.Namespace exposing (namespace)


type CssClasses
    = Menu
    | NewBookmarkButton
    | Footer
    | Brand
    | BrandTitle
    | BrandTagline
    | InfoDialogButton
    | InfoDialog
    | InfoDialogHelp
    | InfoDialogOther
    | InfoDialogHelpTitle
    | Hidden


type CssIds
    = App


css : Stylesheet
css =
    (stylesheet << namespace "bookie")
        [ html
            [ fontFamily sansSerif
            , height <| pct 100
            , overflow hidden
            , padding zero
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
            [ height <| pct 100
            , position relative
            ]
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
        , class Footer
            [ color mediumGray
            , paddingTop <| em 1
            , position absolute
            , bottom <| px 32
            , width <| pct 100
            , displayFlex
            , justifyContent center
            , children
                [ a
                    [ color mediumGray
                    , paddingRight <| px 8
                    , paddingLeft <| px 8
                    ]
                , div
                    [ paddingRight <| px 8
                    , paddingLeft <| px 8
                    ]
                ]
            ]
        , class Brand
            [ color mediumGray
            , displayFlex
            , justifyContent spaceAround
            , width <| px 256
            , alignSelf center
            , fontSize <| em 1.1
            , fontWeight <| int 600
            , property "-webkit-touch-callout" "none"
            , property "-webkit-user-select" "none"
            , property "-khtml-user-select" "none"
            , property "-moz-user-select" "none"
            , property "-ms-user-select" "none"
            , property "user-select" "none"
            ]
        , class BrandTitle
            [ color Colors.gray
            ]
        , class BrandTagline
            []
        , class InfoDialogButton
            [ backgroundColor mediumGray
            , color primaryBackgroundColor
            , height <| px 16
            , width <| px 16
            , border zero
            , borderRadius <| pct 100
            , displayFlex
            , alignSelf center
            , fontSize <| px 10
            , fontWeight <| int 900
            , justifyContent center
            , hover
                [ backgroundColor primaryAccentColor
                ]
            ]
        , class InfoDialog
            [ position absolute
            , height <| px 256
            , width <| px 386
            , backgroundColor <| primaryBackgroundColor
            , border2 (px 1) solid
            , borderRadius <| px 6
            , borderColor <| mediumGray
            , top zero
            , bottom zero
            , right zero
            , left zero
            , margin auto
            , displayFlex
            , justifyContent center
            , padding <| px 16
            , boxShadow5 zero zero (px 24) (px -8) mediumGray
            , zIndex <| int 999
            , flexDirection column
            ]
        , class InfoDialogHelp
            [ fontSize <| em 1.1
            , padding <| px 8
            ]
        , class InfoDialogHelpTitle
            [ fontSize <| em 1.25
            , fontWeight <| int 600
            , paddingBottom <| px 16
            ]
        , class InfoDialogOther
            [ color Colors.gray
            , paddingTop <| px 16
            , padding <| px 8
            ]
        , class Hidden
            [ display none
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
