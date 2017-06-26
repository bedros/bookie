module View
    exposing
        ( bookmarkTableView
        , bookmarkTableHeadersView
        , bookmarkTableRowView
        , bookmarkTableEntryView
        , bookmarkEditorView
        )

import Models exposing (Bookmark)
import Msg exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Maybe exposing (withDefault)


bookmarkTableView : List Bookmark -> Html Msg
bookmarkTableView bookmarks =
    ul
        []
        (bookmarkTableHeadersView
            :: (List.map bookmarkTableRowView bookmarks)
        )


bookmarkTableHeadersView : Html Msg
bookmarkTableHeadersView =
    li
        []
        [ bookmarkTableEntryView "entry-header entry-title" [ text "Title" ]
        , bookmarkTableEntryView "entry-header entry-url" [ text "Url" ]
        , bookmarkTableEntryView "entry-header entry-description" [ text "Description" ]
        ]


bookmarkTableRowView : Bookmark -> Html Msg
bookmarkTableRowView bookmark =
    li
        [ onClick (SelectBookmark bookmark) ]
        [ bookmarkTableEntryView "entry-title" [ text bookmark.title ]
        , bookmarkTableEntryView "entry-url" [ a [] [ text bookmark.url ] ]
        , bookmarkTableEntryView "entry-description" [ text (withDefault "" bookmark.description) ]
        , bookmarkTableEntryView "entry-selector" []
        ]


bookmarkTableEntryView : String -> List (Html Msg) -> Html Msg
bookmarkTableEntryView class_ view_ =
    div [ class class_ ] view_


bookmarkEditorView : Maybe Bookmark -> Html Msg
bookmarkEditorView selectedBookmark =
    case selectedBookmark of
        Just bookmark ->
            div
                [ id "editor" ]
                [ input
                    [ class "editor-form editor-form-title"
                    , defaultValue bookmark.title
                    ]
                    []
                , input
                    [ class "editor-form editor-form-url"
                    , defaultValue bookmark.url
                    ]
                    []
                , input
                    [ class "editor-form editor-form-description"
                    , defaultValue (withDefault "" bookmark.description)
                    ]
                    []
                ]

        Nothing ->
            div [ id "editor" ] []
