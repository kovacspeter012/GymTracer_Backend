# GymTracer_Backend

Backend végpontok

## 1. Regisztráció és Bejelentkezés

- `POST` /api/auth/registration
- `POST` /api/auth/login
- `POST` /api/auth/logout

## 2. Customer tevékenység

- `GET` /api/user/{id}/profile
- `PUT` /api/user/{id}/profile
- `DELETE` /api/user/{id}

- `GET` /api/user/{id}/card
- `POST` /api/user/{id}/card
- `DELETE` /api/user/{id}/card/{card_id}


- `GET` /api/ticket
- `GET` /api/ticket/user/{id}
- `GET` /api/tickets/user/{id}/unpaid
- `POST` /api/ticket/{ticket_id}/user/{id}/{is_paid}
- `POST` /api/ticket/{ticket_id}/user/{id}/pay

- `GET` /api/training
- `GET` /api/training/{training_id}
- `GET` /api/user/{id}/training
- `POST` /api/user/{id}/training/{training_id}
- `DELETE` /api/user/{id}/training/{training_id}

## 3. Trainer tevékenység

- `GET` /api/training/user/{id}
- `POST` /api/training/user/{id}
- `PUT` /api/training/{training_id}/user/{id}
- `DELETE` /api/training/{training_id}/user/{id}
- `PUT` /api/training/{training_id}/user/{id}/attendance

## 4. Staff

- `GET` /api/user (több paraméteres keresés??)
- `GET` /api/statistic/gym
- `GET` /api/statistic/user/{id}


- Customer tevékenységek a nevükben

## 5. Admin

- `PUT` /api/user/{id}/role
- `GET` /api/payment
- `GET` /api/payment/user/{id}

- `GET` /api/statistic/gym (részletesebb)
- `GET` /api/statistic/user/{id}/card

## 6. Kapu

- `POST` /api/card/{card_code}/use (??)
