extends Node


## Diretório dos dados
const MAPS_DATA_DIRECTORY: String = "res://data/maps/"

## Diretório dos gráficos
const CHARACTER_SPRITE_DIRECTORY: String = "res://assets/gfx/characters/"

## Endereço no qual o cliente irá escutar.
const HOST: String = "127.0.0.1"
## Porta TCP/UDP utilizada pelo cliente.
const PORT: int = 7001

## Versão do cliente.
const MAJOR_VERSION: int = 1
const MINOR_VERSION: int = 0
const REVISION_VERSION: int = 0

## Tamanho de cada célula do mapa.
const CELL_SIZE: int = 32

## Nenhum bloqueio.
const CELL_NONE: int = 0
## Bloqueia a célula inteira.
const CELL_FULL_BLOCK: int = 1
## Bloqueia o lado de cima da célula.
const CELL_UP: int = 2
## Bloqueia o lado direito da célula.
const CELL_RIGHT: int = 4
## Bloqueia o lado de baixo da célula.
const CELL_DOWN: int = 8
## Bloqueia o lado esquerdo da célula.
const CELL_LEFT: int = 16

## Sprites disponíveis para criar os personagens.
const AVALIABLE_SPRITES: Array[String] = ["fighter01", "fighter02"]

## Regras de validação dos dados de usuário.
const IDENTIFIER_REGEX: String = "^[a-zA-Z0-9]{4,}$"
const EMAIL_REGEX: String = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
const PASSWORD_REGEX: String = "^(?=.*[0-9])(?=.*[!@#$%^&*(),.?\":{}|<>]).{4,}$"

const SPRITESHEET_COLUMNS: int = 3
const SPRITESHEET_ROWS: int = 4

const ANIMATION_STEP_THRESHOLD: float = 0.5
const MAX_PENDING_MOVES: int = 32

const WALKING_SPEED: float = 5.0
const WARP_COOLDOWN: float = 0.3
