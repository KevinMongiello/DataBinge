# Data Binge
---
Data Binge is an Object Relational Mapping (ORM) tool, and it is based on Active Record.  It is used to make database manipulations easy and painless by using a class for each table which can effortlessly translate information from the database into easily-manipulatable objects.  These classes, or models, enable an easy interface for users to get, set, and change data without ever having to directly access the database.  Model classes are also easily linked to each other through a process of setting a single foreign_key in the database and then appropriately describing the relation as a function name.  Data Binge does all the heavy lifting, as long as the user sticks closely to the suggested naming convention.

In order to understand the relationship between tables, models, associations, etc.  A few rules must be followed.  By using the naming scheme provided, certain default values can be inferred and make configuration a breeze.  Say goodbye to boilerplate!

## Getting Started
---
> If you'd like to play around first with the test file, open up `pry` and load the test file `load 'lib/test.rb'` and start making some queries like `Driver.first.cars` or `Car.first.driver`

- Download the zip or clone the root directory into your working folder.  

- Change the paths in `db/db_connection.rb` to point to your database files.
```ruby
SQL_FILE = File.join(ROOT_FOLDER, 'cars.sql') # Change 'cars.sql' to your sql file
DB_File = File.join(ROOT_FOLDER, 'cars.db')   # Change 'cars.db' to your db file
```
> Note: this step is only if you want to use your own database.  If you want to use the one provided, skip this step.

- Require DataBinge/lib/data_binge into your model files, and define your classes to inherit from DataBinge.
```ruby
require_relative 'data_binge'

class Car < DataBinge
end
```

- Call the class method `finalize!` in order to define instance getter/setter methods related to column names.
```ruby
Car.finalize!
=> [:id, :model, :owner_id] # Car DB columns
```

> There is a test file included to show how to set up a model with associations.

Reminder: the instance variables initialized by `finalize!` are the the column names declared in the database that has been setup in the sql file.  Feel free to call finalize! at the end of the class definition.

## API
---

##Public Class Methods
---
`::columns`
Returns an array of table columns in symbol format of the specified DataBinge class.
```ruby
  class Car < DataBinge
  end

  Car.columns
=> [:id, :model, :owner_id]
```

`::finalize!`
Creates attribute accessor methods for each column field
```ruby
Car.finalize!
# id
# model
# owner_id
```

`::table_name=(name)`
Sets a class instance variable to the name specified.  This is the table name used for SQL querying.
```ruby
Car.table_name = "cars"
# self.table_name => cars
```

`::table_name`
Gets the class table name
```ruby
Car.table_name
=> "cars"
```

`::all`
Returns all rows from the class' table
```ruby
Driver.all
=> [#<Driver:0x007f90f39323e0
  @attributes={:id=>1, :fname=>"Michael", :lname=>"Carillo", :garage_id=>1}>,
 #<Driver:0x007f90f3932200
  @attributes={:id=>2, :fname=>"Laura", :lname=>"Carillo", :garage_id=>1}>,
 #<Driver:0x007f90f3932020
  @attributes={:id=>3, :fname=>"Ryan", :lname=>"Denning", :garage_id=>2}>,
 #<Driver:0x007f90f3931e40
  @attributes={:id=>4, :fname=>"Carlos", :lname=>"Varjano", :garage_id=>nil}>]
```

`::find(id)`
Queries the database for a record with id => id
```ruby
Garage.find(2)
=> #<Garage:0x007fd7e20f5610 @attributes={:id=>2, :address=>"Vance and McGilbert"}>
```

`::first`
Selects the first record in the table
```ruby
Garage.first
=> #<Garage:0x007fd7e3850cd8 @attributes={:id=>1, :address=>"7th and Columbia"}>
```

## Public Instance Methods
---
`#attributes`
Returns the current values for the row object
```ruby
kyle.attributes
=> {:fname=>"Kyle", :lname=>"Berg", :garage_id=>3, :id=>5}
```

`#insert`
Inserts the current object into the database and creates a new row.  Returns the id of the new object.
```ruby
kyle.insert
=> 5

Driver.find(5)
=> #<Driver:0x007fd7e39b4818 @attributes={:id=>5, :fname=>"Kyle", :lname=>"Berg", :garage_id=>3}>
```

`#update`
Overwrites the row attributes of the DataBinge object in the database.
```ruby
kyle
=> #<Driver:0x007fd7e2191b50 @attributes={:fname=>"Kyle", :lname=>"Berg", :garage_id=>3, :id=>5}>
[13] pry(main)> kyle.lname = "Maroney"
=> "Maroney"
[14] pry(main)> kyle.garage_id = 2
=> 2
[15] pry(main)> kyle.update
=> #<Driver:0x007fd7e2191b50 @attributes={:fname=>"Kyle", :lname=>"Maroney", :garage_id=>2, :id=>5}>
Driver.find(5)
=> #<Driver:0x007fbba29fc8a0 @attributes={:id=>5, :fname=>"Kyle", :lname=>"Maroney", :garage_id=>2}>
```

`#save`
If the object has no id, save will insert.  Otherwise, save will update.
```ruby
Kayla = Driver.new(fname: "Kayla", lname: "Porro", garage_id: 6)
=> #<Driver:0x007fe1e4162600 @attributes={:fname=>"Kayla", :lname=>"Porro", :garage_id=>6}>
Kayla.save
=> #<Driver:0x007fe1e4162600 @attributes={:fname=>"Kayla", :lname=>"Porro", :garage_id=>6, :id=>5}>

Kayla.garage_id = 5
=> 5
Kayla.save
=> #<Driver:0x007fe1e4162600 @attributes={:fname=>"Kayla", :lname=>"Porro", :garage_id=>5, :id=>5}>
```


## Associations

- Tables link together through foreign keys
```ruby
class Car < DataBinge
  belongs_to(
    :driver,
    foreign_key: :owner_id
  )
end

mustang.driver
# => #<Driver:0x007f95d39560d0 @attributes={:id=>1, :fname=>"Michael", :lname=>"Carillo", :garage_id=>1}>
```
Notice that the method name and foreign key are different, therefore requiring an explicit foreign key definition. However, the method name `:owner` matches up to the class name, `:owner_id`, and is implicitly inferred.


- Association with full inference
```ruby
class Driver < DataBinge
  belongs_to :garage
end

Driver.first.garage
# => #<Garage:0x007f95d21f96a8 @attributes={:id=>1, :address=>"7th and Columbia"}>
```

- has_one_through associations
```ruby
class Garage < DataBinge
  has_many_through(
    :cars,
    :drivers,
    :cars
  )
end

Garage.first.cars
# => [#<Car:0x007f95d3a508f0 @attributes={:id=>1, :model=>"Mustang Shelby", :owner_id=>1}>,
      #<Car:0x007f95d3a4ba30 @attributes={:id=>2, :model=>"Toyota Camry", :owner_id=>2}>]
```
