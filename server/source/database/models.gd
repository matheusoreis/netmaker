extends RefCounted
class_name Models


## Preenche o modelo com os valores de uma linha do banco de dados.
func from_row(row: Array, cols: PackedStringArray) -> void:
	for i in cols.size():
		set(cols[i], row[i])


## Retorna os valores do modelo em formato de array.
func to_array() -> Array:
	return []


## Modelo dos dados de uma conta.
class AccountModel extends Models:
	## Identificador da conta.
	var id: int
	## Endereço de e-mail da conta.
	var email: String
	## Senha da conta.
	var password: String
	## Nível de acesso da conta.
	var role: int
	## Timestamp do último acesso da conta.
	var access_at: int
	## Timestamp do banimento da conta.
	var banned_at: int
	## Timestamp de criação da conta.
	var created_at: int
	## Timestamp da última atualização da conta.
	var updated_at: int

	## Retorna os dados da conta em formato de array.
	func to_array() -> Array:
		return [
			self.id,
			self.email,
			self.password,
			self.role,
			self.access_at,
			self.banned_at,
			self.created_at,
			self.updated_at
		]


## Modelo dos dados de um personagem.
class CharacterModel extends Models:
	## Identificador do personagem.
	var id: int
	## Nome identificador do personagem.
	var identifier: String
	## Identificador da conta proprietária.
	var account: int
	## Nome do spritesheet do personagem.
	var spritesheet: String
	## Identificador do mapa atual.
	var map: int
	## Posição horizontal atual no mapa.
	var cell_x: int
	## Posição vertical atual no mapa.
	var cell_y: int
	## Direção horizontal para a qual o personagem está virado.
	var facing_x: int
	## Direção vertical para a qual o personagem está virado.
	var facing_y: int
	## Timestamp do último acesso do personagem.
	var access_at: int
	## Timestamp de criação do personagem.
	var created_at: int
	## Timestamp da última atualização do personagem.
	var updated_at: int

	## Retorna os dados do personagem em formato de array.
	func to_array() -> Array:
		return [
			self.id,
			self.identifier,
			self.account,
			self.spritesheet,
			self.map,
			self.cell_x,
			self.cell_y,
			self.facing_x,
			self.facing_y,
			self.access_at,
			self.created_at,
			self.updated_at
		]


## Modelo dos dados de um mapa.
class MapModel extends Models:
	## Identificador do mapa.
	var id: int
	## Nome identificador do mapa.
	var identifier: String
	## Nome do arquivo de música de fundo.
	var bgm: String
	## Nome do arquivo de som ambiente.
	var bgs: String
	## Largura do mapa em células.
	var size_x: int
	## Altura do mapa em células.
	var size_y: int
	## Timestamp de criação do mapa.
	var created_at: int
	## Timestamp da última atualização do mapa.
	var updated_at: int

	## Retorna os dados do mapa em formato de array.
	func to_array() -> Array:
		return [
			self.id,
			self.identifier,
			self.bgm,
			self.bgs,
			self.size_x,
			self.size_y,
			self.created_at,
			self.updated_at
		]


## Modelo dos dados de colisão de uma célula do mapa.
class MapCollisionModel extends Models:
	## Posição horizontal da célula no mapa.
	var cell_x: int
	## Posição vertical da célula no mapa.
	var cell_y: int
	## Flags de bloqueio da célula.
	var flag: int

	## Retorna os dados de colisão em formato de array.
	func to_array() -> Array:
		return [
			self.cell_x,
			self.cell_y,
			self.flag
		]


## Modelo dos dados de uma passagem entre mapas.
class MapWarpModel extends Models:
	## Identificador do mapa de origem.
	var map_id: int
	## Posição horizontal de origem.
	var from_cell_x: int
	## Posição vertical de origem.
	var from_cell_y: int
	## Identificador do mapa de destino.
	var to_map_id: int
	## Posição horizontal de destino.
	var to_cell_x: int
	## Posição vertical de destino.
	var to_cell_y: int
	## Direção horizontal no destino.
	var to_facing_x: int
	## Direção vertical no destino.
	var to_facing_y: int

	## Retorna os dados da passagem em formato de array.
	func to_array() -> Array:
		return [
			self.map_id,
			self.from_cell_x,
			self.from_cell_y,
			self.to_map_id,
			self.to_cell_x,
			self.to_cell_y,
			self.to_facing_x,
			self.to_facing_y
		]
