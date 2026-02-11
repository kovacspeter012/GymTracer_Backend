# GymTracer_Backend

Backend végpontok

## 1. Regisztráció és Bejelentkezés

- `POST` /api/user/registration
- `POST` /api/user/login
- `POST` /api/user/logout

## 2. Customer tevékenység

- `GET` /api/user/{id}/profile
- `PUT` /api/user/{id}/profile
- `DELETE` /api/user/{id}

- `GET` /api/user/{id}/card
- `POST` /api/user/{id}/card
- `DELETE` /api/user/{id}/card/{card_id}

- `GET` /api/ticket
- `GET` /api/user/{id}/ticket
- `POST` /api/user/{id}/ticket/{ticket_id}/{is_paid}

- `GET` /api/training
- `GET` /api/user/{id}/training
- `POST` /api/user/{id}/training/{training_id}
- `DELETE` /api/user/{id}/training/{training_id}

## 3. Trainer tevékenység

- `GET` /api/training