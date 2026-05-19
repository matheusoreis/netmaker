extends RefCounted


const VERSION_MAJOR: int = 1
const VERSION_MINOR: int = 0
const VERSION_REVISION: int = 0

const NETWORK_ADDRESS: String = "0.0.0.0"
const NETWORK_PORT: int = 7720
const NETWORK_MAX_CLIENTS: int = 100
const NETWORK_MAX_TASKS: int = 2048
const NETWORK_POLL_TIME: int = 1

const DATABASE_PATH: String = "user://database/"
const DATABASE_FILENAME: String = "database"
const DATABASE_POLL_TIME: int = 1

const MIN_USERNAME_LENGTH: int = 4
const MAX_USERNAME_LENGTH: int = 30

const MIN_PASSWORD_LENGTH: int = 6
const MAX_PASSWORD_LENGTH: int = 30

const USERNAME_REGEX: String = "^[a-zA-Z0-9_]+$"
