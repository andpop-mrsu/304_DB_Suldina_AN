-- 1. 5 новых пользователей
-- Дата регистрации из системного времени: date('now')
INSERT INTO users (name, email, gender, register_date, occupation_id)
VALUES 
    ('Семонченков Илья Витальевич', 'semonchenkov@student.mrsu.ru', 'male', date('now'),
        (SELECT id FROM occupations WHERE name = 'student')),
    ('Сульдина Алина Николаевна', 'suldina@student.mrsu.ru', 'female', date('now'),
        (SELECT id FROM occupations WHERE name = 'student')),
    ('Тужилкин Егор Витальевич', 'tuzhilkin@student.mrsu.ru', 'male', date('now'),
        (SELECT id FROM occupations WHERE name = 'student')),
    ('Федорова Дарья Алексеевна', 'fedorova@student.mrsu.ru', 'female', date('now'),
        (SELECT id FROM occupations WHERE name = 'student')),
    ('Чадин Евгений Юрьевич', 'chadin@student.mrsu.ru', 'male', date('now'),
        (SELECT id FROM occupations WHERE name = 'student'));

-- 2. 3 новых фильма разных жанров
INSERT INTO movies (title, year)
VALUES 
    ('Голодные игры (The Hunger Games)', 2012),
    ('Достать ножи (Knives Out)', 2019),
    ('Люди Икс: Первый класс (X-Men: First Class)', 2011);

-- Добавляем жанры
INSERT OR IGNORE INTO genres (name) VALUES ('Action');
INSERT OR IGNORE INTO genres (name) VALUES ('Mystery');
INSERT OR IGNORE INTO genres (name) VALUES ('Sci-Fi');

-- Связываем фильмы с жанрами
INSERT INTO movie_genres (movie_id, genre_id)
VALUES 
    ((SELECT id FROM movies WHERE title = 'Голодные игры (The Hunger Games)'), 
     (SELECT id FROM genres WHERE name = 'Action')),
    ((SELECT id FROM movies WHERE title = 'Достать ножи (Knives Out)'), 
     (SELECT id FROM genres WHERE name = 'Mystery')),
    ((SELECT id FROM movies WHERE title = 'Люди Икс: Первый класс (X-Men: First Class)'), 
     (SELECT id FROM genres WHERE name = 'Sci-Fi'));

-- 3. 3 отзыва о новых фильмах
-- Время отзыва также системное: strftime('%s', 'now')
INSERT INTO ratings (user_id, movie_id, rating, timestamp)
VALUES 
    ((SELECT id FROM users WHERE email = 'suldina@student.mrsu.ru'),
     (SELECT id FROM movies WHERE title = 'Голодные игры (The Hunger Games)'),
     5.0, strftime('%s', 'now')),
    ((SELECT id FROM users WHERE email = 'suldina@student.mrsu.ru'),
     (SELECT id FROM movies WHERE title = 'Достать ножи (Knives Out)'),
     4.5, strftime('%s', 'now')),
    ((SELECT id FROM users WHERE email = 'suldina@student.mrsu.ru'),
     (SELECT id FROM movies WHERE title = 'Люди Икс: Первый класс (X-Men: First Class)'),
     4.0, strftime('%s', 'now'));
