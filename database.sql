CREATE TABLE hardware (
  id integer primary key AUTO_INCREMENT,
  provider text not null,
  name text not null);

INSERT INTO hardware(provider, name) VALUES ('Amazon', 'c5');
INSERT INTO hardware(provider, name) VALUES ('Azure', 'H16mr');
