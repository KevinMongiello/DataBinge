CREATE TABLE cars (
  id INTEGER PRIMARY KEY,
  model VARCHAR(255) NOT NULL,
  owner_id INTEGER,

  FOREIGN KEY(owner_id) REFERENCES driver(id)
);

CREATE TABLE drivers (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  garage_id INTEGER,

  FOREIGN KEY(garage_id) REFERENCES garage(id)
);

CREATE TABLE garages (
  id INTEGER PRIMARY KEY,
  address VARCHAR(255) NOT NULL
);

INSERT INTO
  garages (id, address)
VALUES
  (1, "7th and Columbia"), (2, "Vance and McGilbert");

INSERT INTO
  drivers (id, fname, lname, garage_id)
VALUES
  (1, "Michael", "Carillo", 1),
  (2, "Laura", "Carillo", 1),
  (3, "Ryan", "Denning", 2),
  (4, "Carlos", "Varjano", NULL);

INSERT INTO
  cars (id, model, owner_id)
VALUES
  (1, "Mustang Shelby", 1),
  (2, "Chevy Impala", 2),
  (3, "Volkswagen GTI", 3),
  (4, "BMW 325i", 3),
  (5, "Ford Focus", NULL);
