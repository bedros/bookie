module Browser exposing (..)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
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


view : Model -> Dict.Dict Int Bookmark -> Html Msg
view model bookmarks =
    div [ id "browser" ]
        [ viewBrowserTable model bookmarks ]


viewBrowserTable : Model -> Dict.Dict Int Bookmark -> Html Msg
viewBrowserTable model bookmarks =
    ul
        []
        (viewBrowserTableHeader
            :: (List.map (\bkmk -> viewTableRow model bkmk) (Dict.values bookmarks))
        )


viewBrowserTableHeader : Html Msg
viewBrowserTableHeader =
    li
        []
        [ viewTableCell "entry-header entry-title" [ text "Title" ]
        , viewTableCell "entry-header entry-url" [ text "Url" ]
        , viewTableCell "entry-header entry-description" [ text "Description" ]
        ]


viewTableRow : Model -> Bookmark -> Html Msg
viewTableRow model bookmark =
    let
        classes
            = case model.selectedBookmark of
                Just selectedBookmark ->
                    if selectedBookmark.id == bookmark.id
                        then "selected-row"
                    else
                        ""

                Nothing ->
                    ""
    in
        li
            [ onClick (SelectBookmark bookmark)
            , class classes
            ]
            [ viewTableCell "entry-title" [ text bookmark.title ]
            , viewTableCell "entry-url" [ a [] [ text bookmark.url ] ]
            , viewTableCell "entry-description" [ text (withDefault "" bookmark.description) ]
            , viewTableCell "entry-selector" []
            ]


viewTableCell : String -> List (Html Msg) -> Html Msg
viewTableCell class_ view_ =
    div [ class class_ ] view_
