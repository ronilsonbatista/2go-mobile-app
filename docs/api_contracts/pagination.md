# Contrato de Paginação (app-roteiros-core)

## 1. Estratégia de Paginação
O backend `app-roteiros-core` utiliza paginação baseada em query parameters `page` (1-indexed) e `limit`.

---

## 2. Parâmetros da Requisição

```http
GET /admin/users?page=1&limit=10&search=joao HTTP/1.1
Host: api.2go.com
Authorization: Bearer <accessToken>
```

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `page` | Integer | 1 | Número da página solicitada (inicia em 1) |
| `limit` | Integer | 10 | Quantidade de itens por página |
| `search` | String | Opcional | Termo de busca/filtro |

---

## 3. Resposta Padrão Paginada

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "u49a21b3-5e18-4931-8544-a68394848a68",
        "email": "passageiro@2go.com",
        "fullName": "João da Silva"
      }
    ],
    "meta": {
      "total": 45,
      "page": 1,
      "limit": 10,
      "totalPages": 5
    }
  },
  "timestamp": "2026-08-17T11:45:00.000Z"
}
```

---

## 4. DTO de Paginação no Flutter

```dart
class PaginatedResponse<T> {
  final List<T> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;

  PaginatedResponse({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  }) : hasNextPage = page < totalPages;
}
```
