require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade
	attr_reader :id

  def self.new_from_db(row)
    # create a new Student object given a row from the database
		new_student = self.new(row[0], row[1], row[2])
		new_student
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
		
		sql = <<-SQL
			SELECT * 
			FROM students 
			WHERE name = ?
			LIMIT 1
		SQL

		rtn = DB[:conn].execute(sql, name)

		rtn.map do |row|
			self.new_from_db(row)
		end.first
  end
  
	def initialize(id=nil, name, grade)
		@id = id
		@name = name
		@grade = grade
	end

  def save

		if !!id
			self.update
			return
		end

    sql = <<-SQL
      INSERT INTO students (name, grade) 
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
		@id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end
  
	def update
		sql = <<-SQL
			UPDATE students 
			SET name = ?, grade = ?
			WHERE id = ?
		SQL

		DB[:conn].execute(sql, self.name, self.grade, self.id)
	end

	def self.create(name, grade)
		new_stud = self.new(name, grade)
		new_stud.save
		new_stud
	end	

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

 
end
