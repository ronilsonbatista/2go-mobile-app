# Contrato de Paginação

## 1. Estratégia de Paginação
O backend 2GO utiliza a estratégia de paginação baseada em **Range Headers** do protocolo PostgREST do Supabase, suportando também parâmetros legados `offset` / `limit`.

---

## 2. Paginação via Range Headers (Recomendada para Supabase PostgREST)

### Request:
```http
GET /rest/v1/destinations?select=* HTTP/1.1
Host: placeholder.supabase.co
apikey: <SUPABASE_ANON_KEY>
Range: 0-9
Range-Unit: items
```

### Response Headers:
```http
HTTP/1.1 206 Partial Content
Content-Range: 0-9/45
Content-Type: application/json
```

* `0-9`: Itens retornados na página atual (10 itens).
* `/45`: Total absoluto de registros disponíveis na tabela.

---

## 3. Paginação via Parâmetros de Query (Offset & Limit)

### Request:
```http
GET /rest/v1/itineraries?select=*&limit=10&offset=0 HTTP/1.1
```

### DTO de Resposta Paginada (no Flutter Domain):
```dart
class PaginatedResponse<T> {
  final List<T> items;
  final int offset;
  final int limit;
  final int total;
  final bool hasMore;

  PaginatedResponse({
    required this.items,
    required this.offset,
    required this.limit,
    required this.total,
  }) : hasMore = (offset + items.length) < total;
}
```
