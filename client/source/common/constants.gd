extends Node


## Diretório contendo os dados de mapas.
const MAPS_DATA_DIRECTORY: String = "res://data/maps/"

## Diretório contendo os sprites de personagens.
const CHARACTER_SPRITE_DIRECTORY: String = "res://assets/gfx/characters/"


## Endereço no qual o cliente irá conectar.
const HOST: String = "127.0.0.1"
## Porta TCP/UDP utilizada pelo cliente.
const PORT: int = 7001


## Versão do cliente.
const MAJOR_VERSION: int = 1
## Versão secundária do cliente.
const MINOR_VERSION: int = 0
## Revisão do cliente.
const REVISION_VERSION: int = 0


## Tamanho de cada célula do mapa em pixels.
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


## Expressão regular para validação do identificador do personagem.
const IDENTIFIER_REGEX: String = "^[a-zA-Z0-9]{4,}$"
## Expressão regular para validação do endereço de e-mail.
const EMAIL_REGEX: String = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
## Expressão regular para validação da senha.
const PASSWORD_REGEX: String = "^(?=.*[0-9])(?=.*[!@#$%^&*(),.?\":{}&|<>]).{4,}$"


## Quantidade de colunas do spritesheet de personagens.
const SPRITESHEET_COLUMNS: int = 3
## Quantidade de linhas do spritesheet de personagens.
const SPRITESHEET_ROWS: int = 4
## Distância percentual do movimento para ativar a animação de passo.
const ANIMATION_STEP_THRESHOLD: float = 0.5
## Quantidade máxima de movimentos pendentes na fila.
const MAX_PENDING_MOVES: int = 32


## Velocidade de movimento do personagem em células por segundo.
const WALKING_SPEED: float = 5.0
## Tempo de espera após uma passagem entre mapas.
const WARP_COOLDOWN: float = 0.3
