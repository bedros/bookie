module Editor.Style exposing (..)

import Css exposing (..)
import Css.Elements exposing (input, div, li, ul)
import Css.Namespace exposing (namespace)


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
            [ border <| px 1
            , borderColor <| hex "000"
            , displayFlex
            , margin2 zero auto
            , padding4 zero (px 2) zero (px 2)
            , top <| px 10
            , width <| pct 95
            , position relative
            , children
                [ input
                    [ border zero
                    ]
                ]
            ]
        , class Form
            [ padding4 zero (px 2) zero (px 2)
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
            [
            ]
        , class FormDelete
            [ backgroundColor <| hex "dd4444"
            ]
        , class FormSave
            [ backgroundColor <| hex "44dd44"
            ]
        ]
