extends Node

## Diretório dos dados do mapa
const MAPS_DATA_DIRECTORY: String = "res://data/maps/"


## Caminho do arquivo do banco de dados.
const DATABASE_PATH: String = "user://database/"
## Nome do arquivo do banco de dados.
const DATABASE_FILENAME: String = "database"
## Tempo de polling do banco de dados.
const DATABASE_POLL_TIME: int = 1


## Endereço no qual o servidor irá escutar.
const HOST: String = "0.0.0.0"
## Porta TCP/UDP utilizada pelo servidor.
const PORT: int = 7001


## Quantidade máxima de clientes que podem estar conectados simultaneamente.
const MAX_PEERS: int = 100


## Versão principal do servidor.
const MAJOR_VERSION: int = 1
## Versão secundária do servidor.
const MINOR_VERSION: int = 0
## Revisão do servidor.
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


## Mapa inicial dos jogadores.
const START_MAP: int = 1
## Posição inicial dos jogadores.
const START_MAP_POSITION: Vector2i = Vector2i(1, 1)
## Direção inicial dos jogadores.
const START_MAP_FACING: Vector2i = Vector2i.DOWN


## Sprites disponíveis para criar os personagens.
const AVALIABLE_SPRITES: Array[String] = ["fighter01", "fighter02"]


## Expressão regular para validação do identificador do usuário.
const IDENTIFIER_REGEX: String = "^[a-zA-Z0-9]{4,}$"
## Expressão regular para validação do endereço de e-mail.
const EMAIL_REGEX: String = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
## Expressão regular para validação da senha.
const PASSWORD_REGEX: String = "^(?=.*[0-9])(?=.*[!@#$%^&*(),.?\":{}|<>]).{4,}$"


## Quantidade máxima de caracteres permitida em uma mensagem de chat.
const MAX_CHAT_MESSAGE_LENGTH: int = 200
