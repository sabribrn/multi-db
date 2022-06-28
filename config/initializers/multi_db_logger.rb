ActiveRecord::ConnectionAdapters::AbstractAdapter.class_eval do
  alias_method(:origin_log, :log)
  def log(sql, name = 'SQL', binds = [], type_casted_binds = [], statement_name = nil, &block)
    db_used = @config[:replica] ? 'REPLICA' : 'MASTER'
    db_path = File.basename(@config[:database])
    sql = "#{sql} \033[32m<--- THIS QUERY HIT A #{db_used} DB (#{db_path})\033[0m"
    origin_log(sql, name, binds, type_casted_binds, statement_name, &block)
  end
end

