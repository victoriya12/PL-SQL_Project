-- Tables

create table LIB_BOOKS
(
  id               NUMBER not null,
  title            VARCHAR2(50) not null,
  author_id        NUMBER not null,
  genre_id         NUMBER not null,
  number_of_pages  NUMBER not null,
  release_date     DATE not null,
  isbn             NUMBER not null,
  number_of_copies NUMBER,
  insert_date      DATE not null,
  date_change      DATE,
  user_change      VARCHAR2(20) not null,
  books_left       NUMBER
)

alter table LIB_BOOKS
  add constraint LIB_BOOKS_PK primary key (ID);

create table LIB_BOOKS_HISTORY
(
  history_id       NUMBER default "C##VIKI"."LIB_BOOKS_HISTORY_SEQ"."NEXTVAL" not null,
  log_date         DATE,
  id               NUMBER not null,
  title            VARCHAR2(50),
  author_id        NUMBER,
  genre_id         NUMBER,
  number_of_pages  NUMBER,
  release_date     DATE,
  isbn             NUMBER,
  number_of_copies NUMBER,
  insert_date      DATE,
  date_change      DATE,
  user_change      VARCHAR2(20),
  books_left       NUMBER
)


------------------------------------------------------------------------------------------------

create table LIB_CUSTOMERS
(
  id       NUMBER not null,
  username VARCHAR2(40),
  password VARCHAR2(30)
)

alter table LIB_CUSTOMERS
  add constraint LIB_CUSTOMERS_PK primary key (ID);

create table LIB_CUSTOMERS_HISTORY
(
  history_id NUMBER default "C##VIKI"."LIB_CUSTOMERS_HISTORY_SEQ"."NEXTVAL" not null,
  log_date   DATE,
  id         NUMBER not null,
  username   VARCHAR2(40),
  password   VARCHAR2(30)
)

------------------------------------------------------------------------------------------------


create table LIB_NOM_GROUPS
(
  id          NUMBER default "C##VIKI"."LIB_NOM_GROUPS_SEQ"."NEXTVAL" not null,
  description VARCHAR2(100),
  status      NUMBER
)

comment on column LIB_NOM_GROUPS.status
  is '1-active; 0-inactive';
alter table LIB_NOM_GROUPS
  add constraint LIB_NOM_GROUPS_PK primary key (ID);



create table LIB_NOM_ITEMS
(
  id          NUMBER not null,
  group_id    NUMBER,
  description VARCHAR2(150),
  user_change VARCHAR2(20),
  date_change DATE
)

alter table LIB_NOM_ITEMS
  add constraint LIB_NOM_ITEMS_PK primary key (ID);

alter table LIB_NOM_ITEMS
  add constraint LIB_NOM_ITEMS_FK foreign key (GROUP_ID)
  references LIB_NOM_GROUPS (ID);

create table LIB_NOM_ITEMS_HISTORY
(
  history_id  NUMBER default "C##VIKI"."LIB_NOM_ITEMS_HISTORY_SEQ"."NEXTVAL" not null,
  log_date    DATE,
  id          NUMBER,
  group_id    NUMBER,
  description VARCHAR2(150),
  user_change VARCHAR2(50),
  date_change DATE
)

-------------------------------------------------------------------------------------------------

create table LIB_REQUESTS
(
  id           NUMBER not null,
  customer_id  NUMBER,
  book_id      NUMBER,
  request_date DATE,
  status       VARCHAR2(50),
  period       NUMBER,
  deadline     DATE,
  date_change  DATE,
  user_change  VARCHAR2(50)
)

alter table LIB_REQUESTS
  add constraint LIB_REQUESTS_PK primary key (ID);

alter table LIB_REQUESTS
  add constraint LIB_REQUESTS_FK_1 foreign key (CUSTOMER_ID)
  references LIB_CUSTOMERS (ID);

alter table LIB_REQUESTS
  add constraint LIB_REQUESTS_FK_2 foreign key (BOOK_ID)
  references LIB_BOOKS (ID);


create table LIB_REQUESTS_HISTORY
(
  history_id   NUMBER default "C##VIKI"."LIB_REQUESTS_HISTORY_SEQ"."NEXTVAL" not null,
  log_date     DATE,
  id           NUMBER not null,
  customer_id  NUMBER,
  book_id      NUMBER,
  request_date DATE,
  status       VARCHAR2(50),
  period       NUMBER,
  deadline     DATE,
  date_change  DATE,
  user_change  VARCHAR2(50)
)


--------------------------------------------------------------------------------------------------------

-- Triggers

create or replace trigger lib_books_trg_buid
  before insert or update or delete
  on lib_books 
  for each row
declare
  -- local variables here
begin
   if inserting or updating then
    :new.date_change := sysdate;
    :new.user_change := nvl(:new.user_Change, user);
  end if;
  if inserting then
    :new.id          := lib_books_seq.nextval;
    :new.insert_date := sysdate;
  elsif updating or deleting then
    insert into lib_books_history
      (id,
       log_date,
       title,
       author_id,
       genre_id,
       NUMBER_OF_PAGES,
       RELEASE_DATE,
       ISBN,
       NUMBER_OF_COPIES,
       INSERT_DATE,
       date_change,
       user_change,
        BOOKS_LEFT)
    values
      (:old.id,
       sysdate,
       :old.title,
       :old.author_id,
       :old.genre_id,
       :old.number_of_pages,
       :old.release_date,
       :old.isbn,
       :old.number_of_copies,
       :old.insert_date,
       :old.date_change,
       :old.user_change,
       :old.books_left);
  end if;
end lib_books_trg_buid;



create or replace trigger lib_customers_trg_buid
  before insert or update or delete on lib_customers
  for each row
declare
  -- local variables here
begin

  if inserting then
    :new.id       := lib_customers_seq.nextval;
    :new.username := user;
  elsif updating or deleting then
    insert into lib_customers_history
      (log_date,
       id,
       username,
       password)
    values
      (sysdate, :old.id, :old.username, :old.password);
  end if;
end lib_requests_trg_buid;



create or replace trigger lib_nom_items_trg_buid
  before insert or update or delete
  on lib_nom_items 
  for each row
declare
  -- local variables here
begin
   if inserting or updating then
    :new.date_change := sysdate;
    :new.user_change := nvl(:new.user_change, user);
  end if;
  if inserting then
    :new.id          := lib_nom_items_seq.nextval;
  elsif updating or deleting then
    insert into lib_nom_items_history
      (  
log_date, 
id, 
group_id, 
description, 
user_change, 
date_change)
    values
      (
       sysdate,
       :old.id,
       :old.group_id,
       :old.description,
       :old.user_change,
       :old.date_change);
  end if;
end lib_nom_items_trg_buid;



create or replace trigger lib_requests_trg_buid
  before insert or update or delete on lib_requests
  for each row
declare
  cust_id number;
  cursor cust is select * from lib_customers;
begin
  if updating then
    :new.date_Change := sysdate;
    :new.user_change := nvl(:new.user_change, user);
  end if;
  if inserting then
    :new.id           := lib_requests_seq.nextval;
    :new.request_date := sysdate;
    :new.status       := 'NEW';
    :new.deadline     := trunc(sysdate) + :new.period;
    for c in cust 
      loop
        :new.customer_id := case when user=c.username then c.id end;
        end loop;
    
    --:new.user_name := nvl(:new.user_name,user));
  elsif updating or deleting then
    insert into lib_requests_history
      (log_date,
       id,
       customer_id,
       book_id,
       request_date,
       status,
       period,
       deadline,
       date_change,
       user_change)
    values
      (sysdate,
       :old.id,
       :old.customer_id,
       :old.book_id,
       :old.request_date,
       :old.status,
       :old.period,
       :old.deadline,
       :old.date_change,
       :old.user_change);
  end if;
end lib_requests_trg_buid;


-----------------------------------------------------------------------------------
