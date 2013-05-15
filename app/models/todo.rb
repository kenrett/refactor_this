class Todo < ActiveRecord::Base
  attr_accessible :title, :body, :list_name, :todo_count, :status

  before_validation :normalize_list_name
  after_save :update_todo_counts

  state_machine :state, :initial => :incomplete do
    event :in_progress do
      transition all => :in_progress
    end

    event :complete do
      transition all => :completed
    end
  end

  def moved?
    self.status == 3
  end

  def deleted?
    self.status == 4
  end

  def postponed?
    self.status == 5
  end

  def important?
    self.status == 6
  end

  def moved!
    self.update_attributes :status => 3
  end

  def deleted!
    self.update_attributes :status => 4
  end

  def postponed!
    self.update_attributes :status => 5
  end

  def important!
    self.update_attributes :status => 6
  end

  class << self
    def all_moved
      self.where :status => 3
    end

    def all_deleted
      self.where :status => 4
    end

    def all_postponed
      self.where :status => 5
    end

    def all_important
      self.where :status => 6
    end

    def create_by_incomplete
      self.create :status => 0
    end

    def create_by_complete
      self.create :status => 1
    end

    def create_by_in_progress
      self.create :status => 2
    end

    def create_by_moved
      self.create :status => 3
    end

    def create_by_deleted
      self.create :status => 4
    end

    def create_by_postponed
      self.create :status => 5
    end

    def create_by_important
      self.create :status => 6
    end
  end

  private

  def normalize_list_name
    self.list_name = self.list_name.parameterize
  end

  # updates own todo_count and siblings
  # doesn't update todo_count in memory, need to refactor todo_count to be on a TodoList
  def update_todo_counts
    count = Todo.where(:list_name => self.list_name).count
    Todo.where(:list_name => self.list_name).update_all(:todo_count => count)
  end

end
