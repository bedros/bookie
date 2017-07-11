module Browser.Main exposing (..)

import Browser.Style as Style
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.CssHelpers
import Html.Events exposing (onClick, onDoubleClick)
import Bookmark exposing (Bookmark)
import Maybe exposing (withDefault)


type alias Model =
    { selectedBookmark : Maybe Bookmark
    , sortBy : Sortable
    , sortAscending : Bool
    }


type Msg
    = SelectBookmark Bookmark
    | DeselectBookmark
    | Sort Sortable


type BrowserMsg
    = BrowserSelection (Maybe Bookmark)
    | NoOp


type Sortable
    = SortTitle
    | SortUrl
    | Unsorted


init : Model
init =
    Model Nothing Unsorted True



------------
-- Update --
------------


update : Msg -> Model -> ( Model, BrowserMsg, Cmd msg )
update msg model =
    case msg of
        SelectBookmark bookmark ->
            ( { model | selectedBookmark = Just bookmark }
            , BrowserSelection (Just bookmark)
            , Cmd.none
            )

        DeselectBookmark ->
            ( { model | selectedBookmark = Nothing }
            , BrowserSelection Nothing
            , Cmd.none
            )

        Sort sortable ->
            case model.sortBy of
                Unsorted ->
                    ( { model
                        | sortBy = sortable
                        , sortAscending = True
                      }
                    , NoOp
                    , Cmd.none
                    )

                _ ->
                    ( { model
                        | sortBy = sortable
                        , sortAscending = toggleSortDirection model sortable
                      }
                    , NoOp
                    , Cmd.none
                    )


toggleSortDirection : Model -> Sortable -> Bool
toggleSortDirection model sortable =
    if (model.sortBy == sortable) then
        not model.sortAscending
    else
        True


sort : Sortable -> Bool -> List Bookmark -> List Bookmark
sort sortable ascending bookmarks =
    let
        sorted =
            case sortable of
                SortTitle ->
                    List.sortBy .title bookmarks

                SortUrl ->
                    List.sortBy .url bookmarks

                Unsorted ->
                    bookmarks
    in
        case sortable of
            Unsorted ->
                bookmarks

            _ ->
                if (not ascending) then
                    List.reverse sorted
                else
                    sorted


formatLink : String -> String
formatLink url =
    if String.contains "//" url then
        url
    else
        "http://" ++ url



----------
-- View --
----------


{ id, class, classList } =
    Html.CssHelpers.withNamespace "bookie"


view : Model -> Dict.Dict Int Bookmark -> Html Msg
view model bookmarks =
    div [ id Style.Browser ]
        [ viewBrowserTable model bookmarks ]


viewBrowserTable : Model -> Dict.Dict Int Bookmark -> Html Msg
viewBrowserTable model bookmarks =
    ul
        []
        ((viewBrowserTableHeader model.sortBy model.sortAscending)
            :: (List.map
                    (\bkmk -> viewTableRow model bkmk)
                    (Dict.values bookmarks
                        |> sort model.sortBy model.sortAscending
                    )
               )
        )


viewBrowserTableHeader : Sortable -> Bool -> Html Msg
viewBrowserTableHeader sortable ascending =
    li
        []
        [ viewTableCell
            [ class [ Style.Header, Style.HeaderLeft, Style.Title, Style.Sortable ]
            , onClick (Sort SortTitle)
            ]
            [ div
                []
                [ text "Title" ]
            , viewSortIcon SortTitle sortable ascending
            ]
        , viewTableCell
            [ class [ Style.Header, Style.Url, Style.Sortable ]
            , onClick (Sort SortUrl)
            ]
            [ div
                []
                [ text "Url" ]
            , viewSortIcon SortUrl sortable ascending
            ]
        , viewTableCell
            [ class [ Style.Header, Style.HeaderRight, Style.Description ]
            ]
            [ div
                []
                [ text "Description" ]
            ]
        ]


viewSortIcon : Sortable -> Sortable -> Bool -> Html Msg
viewSortIcon header sortable ascending =
    if (header == sortable) then
        case ascending of
            True ->
                div [ class [ Style.Sorted ] ] [ text "↑" ]

            False ->
                div [ class [ Style.Sorted ] ] [ text "↓" ]
    else
        div [] [ text "" ]


viewTableRow : Model -> Bookmark -> Html Msg
viewTableRow model bookmark =
    let
        classes =
            case model.selectedBookmark of
                Just selectedBookmark ->
                    if selectedBookmark.id == bookmark.id then
                        Style.RowSelected
                    else
                        Style.None

                Nothing ->
                    Style.None
    in
        li
            [ class [ classes ]
            ]
            [ viewTableCell
                [ class [ Style.Title ]
                ]
                [ text bookmark.title ]
            , viewTableCell
                [ class [ Style.Url ]
                ]
                [ a
                    [ href (formatLink bookmark.url)
                    , target "_blank"
                    ]
                    [ text bookmark.url ]
                ]
            , viewTableCell
                [ class [ Style.Description ]
                ]
                [ text (withDefault "" bookmark.description) ]
            , viewTableCell
                [ class [ Style.Selector ]
                , onClick (SelectBookmark bookmark)
                ]
                []
            ]


viewTableCell : List (Html.Attribute Msg) -> List (Html Msg) -> Html Msg
viewTableCell attributes view_ =
    div attributes view_
