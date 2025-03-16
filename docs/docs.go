// Package docs Code generated by swaggo/swag. DO NOT EDIT
package docs

import "github.com/swaggo/swag"

const docTemplate = `{
    "schemes": {{ marshal .Schemes }},
    "swagger": "2.0",
    "info": {
        "description": "{{escape .Description}}",
        "title": "{{.Title}}",
        "termsOfService": "http://swagger.io/terms/",
        "contact": {
            "name": "API Support",
            "email": "support@galatea.com"
        },
        "license": {
            "name": "Apache 2.0",
            "url": "http://www.apache.org/licenses/LICENSE-2.0.html"
        },
        "version": "{{.Version}}"
    },
    "host": "{{.Host}}",
    "basePath": "{{.BasePath}}",
    "paths": {
        "/api/v1/substrates": {
            "get": {
                "description": "Get a list of all substrates",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "substrates"
                ],
                "summary": "List all substrates",
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "type": "array",
                            "items": {
                                "$ref": "#/definitions/substrate.SubstrateResponse"
                            }
                        }
                    },
                    "500": {
                        "description": "Internal server error",
                        "schema": {
                            "$ref": "#/definitions/substrate.ErrorResponse"
                        }
                    }
                }
            },
            "post": {
                "description": "Create a new substrate with the provided information",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "substrates"
                ],
                "summary": "Create a new substrate",
                "parameters": [
                    {
                        "description": "Substrate information",
                        "name": "substrate",
                        "in": "body",
                        "required": true,
                        "schema": {
                            "$ref": "#/definitions/substrate.SubstrateRequest"
                        }
                    }
                ],
                "responses": {
                    "201": {
                        "description": "Created",
                        "schema": {
                            "$ref": "#/definitions/substrate.SubstrateResponse"
                        }
                    },
                    "400": {
                        "description": "Invalid request body",
                        "schema": {
                            "$ref": "#/definitions/substrate.ErrorResponse"
                        }
                    },
                    "500": {
                        "description": "Internal server error",
                        "schema": {
                            "$ref": "#/definitions/substrate.ErrorResponse"
                        }
                    }
                }
            }
        },
        "/api/v1/substrates/{id}": {
            "get": {
                "description": "Get a substrate by its ID",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "substrates"
                ],
                "summary": "Get a substrate by ID",
                "parameters": [
                    {
                        "type": "string",
                        "description": "Substrate ID",
                        "name": "id",
                        "in": "path",
                        "required": true
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "$ref": "#/definitions/substrate.SubstrateResponse"
                        }
                    },
                    "404": {
                        "description": "Substrate not found",
                        "schema": {
                            "$ref": "#/definitions/substrate.ErrorResponse"
                        }
                    }
                }
            },
            "put": {
                "description": "Update a substrate with the provided information",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "substrates"
                ],
                "summary": "Update a substrate",
                "parameters": [
                    {
                        "type": "string",
                        "description": "Substrate ID",
                        "name": "id",
                        "in": "path",
                        "required": true
                    },
                    {
                        "description": "Updated substrate information",
                        "name": "substrate",
                        "in": "body",
                        "required": true,
                        "schema": {
                            "$ref": "#/definitions/substrate.SubstrateRequest"
                        }
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "$ref": "#/definitions/substrate.SubstrateResponse"
                        }
                    },
                    "400": {
                        "description": "Invalid request body",
                        "schema": {
                            "$ref": "#/definitions/substrate.ErrorResponse"
                        }
                    },
                    "500": {
                        "description": "Internal server error",
                        "schema": {
                            "$ref": "#/definitions/substrate.ErrorResponse"
                        }
                    }
                }
            },
            "delete": {
                "description": "Delete a substrate by its ID",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "substrates"
                ],
                "summary": "Delete a substrate",
                "parameters": [
                    {
                        "type": "string",
                        "description": "Substrate ID",
                        "name": "id",
                        "in": "path",
                        "required": true
                    }
                ],
                "responses": {
                    "204": {
                        "description": "No Content"
                    },
                    "500": {
                        "description": "Internal server error",
                        "schema": {
                            "$ref": "#/definitions/substrate.ErrorResponse"
                        }
                    }
                }
            }
        }
    },
    "definitions": {
        "substrate.ErrorResponse": {
            "type": "object",
            "properties": {
                "error": {
                    "type": "string"
                }
            }
        },
        "substrate.SubstrateRequest": {
            "type": "object",
            "required": [
                "color",
                "name"
            ],
            "properties": {
                "color": {
                    "type": "string"
                },
                "name": {
                    "type": "string"
                }
            }
        },
        "substrate.SubstrateResponse": {
            "type": "object",
            "properties": {
                "color": {
                    "type": "string"
                },
                "id": {
                    "type": "string"
                },
                "name": {
                    "type": "string"
                }
            }
        }
    },
    "securityDefinitions": {
        "ApiKeyAuth": {
            "type": "apiKey",
            "name": "Authorization",
            "in": "header"
        }
    }
}`

// SwaggerInfo holds exported Swagger Info so clients can modify it
var SwaggerInfo = &swag.Spec{
	Version:          "1.0",
	Host:             "localhost:2000",
	BasePath:         "/",
	Schemes:          []string{},
	Title:            "Galatea API",
	Description:      "API REST para la gestión de sustratos y mezclas para cultivos",
	InfoInstanceName: "swagger",
	SwaggerTemplate:  docTemplate,
	LeftDelim:        "{{",
	RightDelim:       "}}",
}

func init() {
	swag.Register(SwaggerInfo.InstanceName(), SwaggerInfo)
}
