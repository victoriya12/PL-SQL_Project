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


create or replace package body library is

procedure signup_customer(p_password in lib_customers.password%TYPE) is
  v_count number;
  
  cursor c_users is
      select * from lib_customers;
   
  user_exist  exception;
  begin
    
    for c in c_users loop
      select count(*)
        into v_count
        from lib_customers l
       where l.username = c.username;
    
      if v_count > 0 then
        raise user_exist;
        goto break_procedure;
      end if;
    
    end loop;
  
    if p_password is not null then
            dbms_output.put_line('Sign up successful! Welcome to the library!');
      insert into lib_customers (password) values (p_password);
    end if;
    commit;
    
   <<break_procedure>>
   null; 
    exception 
        when user_exist then
      DBMS_OUTPUT.PUT_LINE('User with this username already exists!');
  
end signup_customer;

function login_customer(user_name IN VARCHAR2, pass IN VARCHAR2)
   return number IS
   success number;
    v_pass  lib_customers.password%TYPE;
    
    user_exist         EXCEPTION;
    incorrect_password EXCEPTION;
  
  BEGIN

    SELECT password
      INTO v_pass
      FROM lib_customers
     WHERE username LIKE user_name;
  
    IF v_pass LIKE pass THEN
      DBMS_OUTPUT.PUT_LINE('User ' || user_name || ' loging successful');
       success:=1;
       return success;
    ELSE
      RAISE incorrect_password;
       success:=0;
       return success;
    END IF;
  
  EXCEPTION
    WHEN no_data_found OR incorrect_password THEN
      DBMS_OUTPUT.PUT_LINE('No such user! Incorrect username or password!');
    

end login_customer;

function cust_limitBooks(p_user_name lib_customers.username%TYPE) return number is
    res number;
    lim number;
    v_count number;
  begin
  
    select count(c.username)
      into lim
      from lib_customers c
      join lib_requests  r
        on c.id = r.customer_id
     where --r.status <> 'RETURNED' AND
     c.username = p_user_name;
  
    if lim >= 5 then
      dbms_output.put_line('You cannot rent more than 5 books!');
      res:=0;
      return res;
    end if;
    if lim < 5 then
      v_count := 5 - lim;
      dbms_output.put_line('You have the permission to rent ' || v_count  || ' more books until reaching the limit of 5 books per user!');
       res:=1;
       return res;
   end if;
   
    
end cust_limitBooks;

procedure lib_status is
    TYPE num IS TABLE OF lib_REQUESTS.BOOK_ID%TYPE;
    res num;
  
  begin
    
    update lib_requests r
       set r.status = 'EXPIRED', r.user_change = 'SYSTEM'
     where r.status = 'TAKEN'
       AND trunc(r.request_date) < trunc(sysdate) - 1
    returning r.book_id bulk collect into res;
  
    FOR i in 1 .. res.count loop
      update lib_books b
         set b.books_left = b.books_left + 1
       where b.id = res(i);
    end loop;
  
end lib_status;

procedure lib_showAll is
    
    cursor c_authors is
      select i.name from lib_authors i;
  
    type c_list is table of lib_authors.name%TYPE;
    name_list c_list := c_list();
    counter   integer := 0;
  
  begin
    
    for i in c_authors loop
      counter := counter + 1;
      name_list.extend;
      name_list(counter) := i.name;
      dbms_output.put_line('Author (' || counter || ') ' ||
                           name_list(counter));
    end loop;
  
end lib_showAll;

function update_num_books_validation(p_title     in lib_books.title%TYPE,
                                       p_num_books in number,
                                       p_result    out number) return number is
    old  number;
    left number;
  
  begin
    
    SELECT b.number_of_copies, b.books_left
      INTO OLD,
      LEFT FROM lib_books b
     WHERE (B.title) = (p_title);
  
    if old > p_num_books and p_num_books < (old - left) then
      
      dbms_output.put_line('The number of taken books for now is higher than the new value for number of copies field!');
      p_result := 0;
      dbms_output.put_line(p_result);
    
      return p_result;
      
    else
      p_result := 1;
      dbms_output.put_line(p_result);
      return p_result;
    
    end if;
  
end update_num_books_validation;

procedure limit_books_validation(p_title     in lib_books.title%TYPE,
                                 p_num_books in number) is
  
    old      number;
    left     number;
    left_new number;
    l_result number;
  
  begin
    l_result := update_num_books_validation(p_title, p_num_books, l_result);
    --dbms_output.put_line(l_result);
  
    SELECT B.NUMBER_OF_COPIES, B.BOOKS_LEFT
      INTO OLD,
      LEFT FROM lib_books B
     WHERE upper(B.title) = upper(p_title);
  
    if l_result = 1 then
      IF OLD > p_num_books AND p_num_books >= (OLD - LEFT) then
      
        left_new := p_num_books - (OLD - LEFT);
      
      ELSIF OLD <= p_num_books THEN
      
        left_new := p_num_books - (OLD - LEFT);
      
      ELSIF OLD = LEFT AND p_num_books = 0 THEN  --no taken books here
        
        left_new := p_num_books - (OLD - LEFT);
      
   END IF;
    
      update lib_books
         set books_left       = nvl(left_new, books_left),
             number_of_copies = p_num_books
       where upper(title) = upper(p_title);
      commit;
    
    else
      dbms_output.put_line('Invalid operations!');
    end if;
  
end limit_books_validation;

procedure rent_book(p_user_name      in lib_customers.username%TYPE,
                      p_pass         in lib_customers.password%TYPE,
                      p_title        in lib_books.title%TYPE,
                      p_period       in number,
                      p_books_wanted in number) is
                      
    v_result number;
    v_cust_limit_result number;
  
    v_no_book_count number;
    v_already_rented_count number;
    
    v_book_id    lib_books.id%TYPE;
    v_books_left number;
  
    no_book_found         exception;
    too_much_books_wanted exception;
    already_rented_book   exception;
    no_books_left         exception;
  
    cursor books is
      select * from lib_books b where b.title = p_title;
  
  begin
    -- existing book/no book found --> already_rented --> not enough books left --> rent
  
    v_result:=login_customer(p_user_name, p_pass);
    
  if v_result = 1 then 
     
    for b in books loop 
       select count(*)
        into v_no_book_count
        from lib_books l
       where l.title = b.title;
    
      if v_no_book_count = 0 then
        raise no_book_found;
        goto break_procedure;
       
      else
        select count(*)
        into v_already_rented_count
        from lib_books lb
        join lib_requests r
          on r.book_id = lb.id
        join lib_customers c
          on c.id = r.customer_id
       where lb.title = b.title and r.status = 'TAKEN';
     
        if v_already_rented_count > 0 then 
           raise already_rented_book;
           goto break_procedure;
           
       else
          v_cust_limit_result := cust_limitBooks(p_user_name);
          
        if v_cust_limit_result = 1 then 
          
           select lb.id, lb.books_left
          into v_book_id, v_books_left
          from lib_books lb
         where lb.title = b.title;
      
        if p_books_wanted <= v_books_left and p_period is not null then
          update lib_books lb
             set lb.books_left = v_books_left - p_books_wanted
           where lb.title = b.title
             and lb.id = v_book_id;
        
          insert into lib_requests
            (book_id, period)
          values
            (v_book_id, p_period);
        
          dbms_output.put_line('You rented this book successfully!');
          commit;
          
        elsif v_books_left = 0 then
          raise no_books_left;
          goto break_procedure;
        else
          raise too_much_books_wanted;
          goto break_procedure;
        end if;
        
       elsif v_cust_limit_result = 0 then 
         goto break_procedure;
    end if;
       
     end if;   
          
  end if; 
  
  end loop;
  
  else 
    goto break_procedure;
    
 end if;
    

  
  
 <<break_procedure>>
  null;
 
  exception
    when no_book_found then
      dbms_output.put_line('No such book found in the library!');
    when too_much_books_wanted then
      dbms_output.put_line('The number of copies of this book that you want is too much!');
    when already_rented_book then
      dbms_output.put_line('You have already rented this book!');
    when no_books_left then 
      dbms_output.put_line('No more books left! Coming soon...');

      
  
    
  end rent_book;


end library;




