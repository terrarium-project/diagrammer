module Init exposing (..)

import Dict exposing (Dict)
import Math.Vector2 exposing (..)
import List exposing (..)
import Model exposing (..)
import Shape
import State exposing (Msg(..))
import Util exposing (..)


type alias Flags =
    { library : LibraryDef }


type alias LibraryDef =
    { processes : List ProcessDef }


type alias ProcessDef =
    { name : String
    , excerpt : String
    , image : Maybe String
    , inputs : List JackDef
    , outputs : List JackDef
    }


type alias JackDef =
    { name : String
    , rate : Float
    , units : String
    , per : String
    , state : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( processes, jacks, num ) =
            let
                step def ( ps, js, i ) =
                    (parseProcessWithJacks i def) |> \( p, js0 ) -> ( p :: ps, js ++ js0, i + 1 )
            in
                List.foldl step ( [], [], 0 ) flags.library.processes

        processByID : ProcessDict
        processByID =
            processes |> toDictByID

        jackByID : JackDict
        jackByID =
            jacks |> toDictByID

        linkByID : LinkDict
        linkByID =
            Dict.empty

        containerByID : ContainerDict
        containerByID =
            containers |> (List.map mkContainer) |> toDictByID
    in
        ( { processByID = processByID
          , jackByID = jackByID
          , containerByID = containerByID
          , linkByID = linkByID
          , epoch = 0
          , playing = False
          , jacksVisible = True
          , ignoreContainerCapacity = False
          , drag = Nothing
          , selected = Nothing
          , globalTransform = { translate = vec2 0 300, scale = 1.0 }
          , calcCache = Dict.empty
          }
        , Cmd.none
        )


parseProcessWithJacks : Int -> ProcessDef -> ( Process, List Jack )
parseProcessWithJacks n ({ inputs, outputs } as def) =
    let
        process =
            parseProcess n def

        parseInput =
            parseJack process Input

        parseOutput =
            parseJack process Output

        jacks =
            (indexedMap parseInput inputs) ++ (indexedMap parseOutput outputs)
    in
        ( process, jacks )


parseProcess : Int -> ProcessDef -> Process
parseProcess n { name, excerpt, image } =
    let
        x =
            if n % 2 == 0 then
                -500
            else
                -100

        y =
            (-600 + (toFloat n) * 200)
    in
        { id = generateProcessID name
        , name = name
        , description = excerpt
        , imageURL = image
        , position = vec2 x y
        , rect = ( 160, 160 )
        }


parseJack : Process -> JackDirection -> Int -> JackDef -> Jack
parseJack process direction order { name, rate, units, per, state } =
    let
        h =
            Tuple.second Shape.jackDimensions

        y =
            toFloat <| h - h * order

        offset =
            case direction of
                Input ->
                    vec2 -180 y

                Output ->
                    vec2 80 y

        matterState =
            case state of
                "solid" ->
                    SolidState

                "liquid" ->
                    LiquidState

                "gas" ->
                    GasState

                "energy" ->
                    EnergyState

                "light" ->
                    LightState

                _ ->
                    UnspecifiedState
    in
        { id = generateJackID process.name name direction
        , name = name
        , processID = process.id
        , rate = rate
        , units = units
        , per = per
        , direction = direction
        , position = add process.position offset
        , rect = Shape.jackDimensions
        , matterState = matterState
        }


containers =
    [ { id = generateContainerID "Sun", name = "Sun", position = vec2 600 100, unitDisplay = Just "kWh/day" }
    ]


mkContainer : { a | name : String, position : Vec2, unitDisplay : Maybe String } -> Container
mkContainer { name, position, unitDisplay } =
    { id = generateContainerID name
    , name = name
    , position = position
    , unitDisplay = unitDisplay
    , radius = 80
    , capacity = 1 / 0
    , initialAmount = 1 / 0
    }
