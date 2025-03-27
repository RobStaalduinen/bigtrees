class UpdateStatusEnum < ActiveRecord::Migration[6.0]
  def self.up
    execute <<-SQL
      UPDATE estimates
      SET status = status * 10;
    SQL
  end

  def self.down
    execute <<-SQL
      UPDATE estimates
      SET status = status / 10;
    SQL
  end
end
