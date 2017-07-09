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
    }


type Msg
    = SelectBookmark Bookmark
    | DeselectBookmark


type BrowserMsg
    = BrowserSelection (Maybe Bookmark)


init : Model
init =
    Model Nothing



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
        (viewBrowserTableHeader
            :: (List.map
                    (\bkmk -> viewTableRow model bkmk)
                    (Dict.values bookmarks)
               )
        )


viewBrowserTableHeader : Html Msg
viewBrowserTableHeader =
    li
        []
        [ viewTableCell
            [ class [ Style.Header, Style.HeaderLeft, Style.Title ] ]
            [ text "Title" ]
        , viewTableCell
            [ class [ Style.Header, Style.Url ] ]
            [ text "Url" ]
        , viewTableCell
            [ class [ Style.Header, Style.HeaderRight, Style.Description ] ]
            [ text "Description" ]
        ]


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
                [ a [ href bookmark.url ] [ text bookmark.url ] ]
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
