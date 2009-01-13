class ViewStatistics #:nodoc:

  def initialize(*pairs)
    @pairs      = pairs
    @statistics = calculate_statistics
    @total      = calculate_total if pairs.length > 1
  end

  def to_s
    print_header
    @pairs.each { |pair| print_line(pair.first, @statistics[pair.first]) }
    print_splitter
  
    if @total
      print_line("Total", @total)
      print_splitter
    end

    print_erb_test_stats
  end

  private
    def calculate_statistics
      @pairs.inject({}) { |stats, pair| stats[pair.first] = calculate_directory_statistics(pair.last); stats }
    end

    def calculate_directory_statistics(directory, pattern = /.*\.(rhtml|erb|rjs)$/)
      stats = { "lines" => 0, "erblines" => 0, "classes" => 0, "methods" => 0 }

      Dir.foreach(directory) do |file_name| 
        if File.stat(directory + "/" + file_name).directory? and (/^\./ !~ file_name)
          newstats = calculate_directory_statistics(directory + "/" + file_name, pattern)
          stats.each { |k, v| stats[k] += newstats[k] }
        end

        next unless file_name =~ pattern

        f = File.open(directory + "/" + file_name)
        inside_erb = false

        while line = f.gets
          stats["lines"]     += 1

          # every line in an rjs template counts as code 
          stats["erblines"]  += 1 and next if file_name =~ /\.rjs$/

          # each erb output sequence adds one to the erb line count
          stats["erblines"] += ( line.split('<%=').length - 1 )

          # a one-line non-output sequence
          #if line =~ /<%[^=]+.*%>/ then 
          #   stats["erblines"] += 1 and next
          #end

          # stop counting erb lines if you've met an end
          inside_erb = false if line.include?( '%>' ) && ! line.include?( '<%=' )

          inside_erb ||= line =~ /<%[^=]+/ 

          next unless inside_erb

          unless line =~ /^\s*$/ or 
              line =~ /^\s*#/ or
              line =~ /^\s*<%\s*$/ or
              line =~ /^\s*%>\s*$/

            stats["erblines"] += 1 
          end

        end
      end

      stats
    end

    def calculate_total
      total = { "lines" => 0, "erblines" => 0 }
      @statistics.each_value { |pair| pair.each { |k, v| total[k] += v } }
      total
    end

    def calculate_erb
      erb_loc = 0
      @statistics.each { |k, v| erb_loc += v['erblines'] }
      erb_loc
    end

    def print_header
      print_splitter
      puts "| Name                 | Lines |  ERB  | ------- | ------- | --- | ----- |"
      print_splitter
    end

    def print_splitter
      puts "+----------------------+-------+-------+---------+---------+-----+-------+"
    end

    def print_line(name, statistics)

      start = "| #{name.ljust(20)} "

      puts start + 
           "| #{statistics["lines"].to_s.rjust(5)} " +
           "| #{statistics["erblines"].to_s.rjust(5)} " +
           "| #{''.to_s.rjust(7)} " +
           "| #{''.to_s.rjust(7)} " +
           "| #{''.rjust(3)} " +
           "| #{''.to_s.rjust(5)} |"
    end

    def print_erb_test_stats
      erb  = calculate_erb

      puts ""
    end
  end
