module Search.Main exposing (..)

import Simple.Fuzzy as Fuzzy
import Bookmark exposing (Bookmark)
import Html exposing (..)
import Html.Attributes exposing (placeholder)
import Html.Events exposing (onInput)
import Html.CssHelpers
import Set
import Dict
import Search.Style as Style


type alias Model =
    { query : String
    }


type Msg
    = Search String


type SearchMsg
    = SearchResult (List Bookmark)


init : Model
init =
    Model ""



------------
-- Update --
------------


update : Msg -> Model -> (Dict.Dict Int Bookmark) -> ( Model, SearchMsg, Cmd msg )
update msg model bookmarks =
    case msg of
        Search query ->
            ( { model | query = query }
            , SearchResult <| search query (Dict.values bookmarks)
            , Cmd.none
            )


search : String -> List Bookmark -> List Bookmark
search query bookmarks =
    let
        titles =
            Fuzzy.filter .title query bookmarks

        urls =
            Fuzzy.filter .url query bookmarks
    in
        mergeLists .id titles urls



mergeLists : (a -> comparable) -> List a -> List a -> List a
mergeLists field listA listB =
    let
        fields =
            List.filterMap (\a -> Just <| field a) listA
    in
        filterList field listB (Set.fromList fields) listA


filterList : (a -> comparable) -> List a -> Set.Set comparable -> List a -> List a
filterList field list keys result =
    case list of
        item :: rest ->
            let
                ( newKeys, newResult ) =
                    addUniqueToList field item keys result
            in
                filterList field rest keys newResult

        [] ->
            result


addUniqueToList : (a -> comparable) -> a -> Set.Set comparable -> List a -> ( Set.Set comparable, List a )
addUniqueToList field item keys items =
    if (Set.member (field item) keys) then
        ( keys, items )
    else
        ( Set.insert (field item) keys
        , items ++ [ item ]
        )



----------
-- View --
----------


{ id, class, classList } =
    Html.CssHelpers.withNamespace "bookie"


view : Model -> Html Msg
view model =
    div
        [ id Style.Search ]
        [ input
            [ class [ Style.SearchBox ]
            , onInput Search
            , placeholder "search"
            ]
            []
        ]
