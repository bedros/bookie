module Editor.Style exposing (..)

import Css exposing (..)
import Css.Elements exposing (button, input, div, li, ul)
import Css.Namespace exposing (namespace)
import Style as Base


type CssClasses
    = Form
    | FormTitle
    | FormUrl
    | FormDescription
    | FormCancel
    | FormDelete
    | FormSave


type CssIds
    = Editor


css : Stylesheet
css =
    (stylesheet << namespace "bookie")
        [ id Editor
            []
        , class Form
            [ margin2 zero auto
            , padding <| px 8
            , top <| px 10
            , position relative
            , children
                [ input
                    [ border3 (px 1) solid Base.mediumGray
                    , borderRadius <| px 3
                    , padding <| px 4
                    , margin <| px 4
                    ]
                , button
                    [ border3 (px 1) solid Base.mediumGray
                    , borderRadius <| px 3
                    , padding <| px 4
                    , margin <| px 4
                    ]
                ]
            , displayFlex
            , border3 (px 1) solid Base.mediumGray
            , borderRadius <| px 6
            ]
        , class FormTitle
            [ width <| pct 25
            ]
        , class FormUrl
            [ width <| pct 40
            ]
        , class FormDescription
            [ width <| pct 35
            ]
        , class FormCancel
            [ backgroundColor Base.warningColor
            , color Base.whiteColor
            , hover
                [ backgroundColor Base.warningSaturatedColor
                ]
            ]
        , class FormDelete
            [ backgroundColor Base.dangerColor
            , color Base.whiteColor
            , hover
                [ backgroundColor Base.dangerSaturatedColor
                ]
            ]
        , class FormSave
            [ backgroundColor Base.successColor
            , color Base.whiteColor
            , hover
                [ backgroundColor Base.successSaturatedColor
                ]
            ]
        ]
