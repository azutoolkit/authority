# Compatibility layer for CQL and Azu dashboard integration
# This patches CQL's monitor to provide APIs expected by older Azu versions

require "cql"

# PostgreSQL UUID compatibility for CQL ActiveRecord
# CQL stores UUIDs as String internally, but PostgreSQL returns native UUID objects.
# This converter handles both cases by patching PG::ResultSet.
class ::PG::ResultSet
  # Override read for String to handle UUID conversion from PostgreSQL
  def read(type : String.class) : String
    val = read
    case val
    when UUID
      val.to_s
    when String
      val
    when Nil
      raise DB::Error.new("Cannot convert nil to String")
    else
      val.to_s
    end
  end

  def read(type : String?.class) : String?
    val = read
    case val
    when UUID
      val.to_s
    when String
      val
    when Nil
      nil
    else
      val.to_s
    end
  end
end

module CQL::Performance
  # Null object profiler that returns safe defaults
  class NullQueryProfiler
    include QueryProfilerInterface

    def record_query(sql : String, params : Array(DB::Any),
                     execution_time : Time::Span,
                     rows_affected : Int64? = nil,
                     error : String? = nil) : Void
    end

    def statistics
      {} of String => NamedTuple(
        count: Int32,
        total_ms: Float64,
        avg_ms: Float64,
        min_ms: Float64,
        max_ms: Float64,
        execution_count: Int64,
        total_time: Time::Span,
        avg_time: Time::Span,
        min_time: Time::Span,
        max_time: Time::Span)
    end

    def slowest_queries(limit : Int32) : Array(QueryData)
      [] of QueryData
    end

    def slow_queries(limit : Int32) : Array(QueryData)
      [] of QueryData
    end

    def issues : Array(Issue)
      [] of Issue
    end

    def clear : Void
    end
  end

  # Null object detector
  class NullNPlusOneDetector
    include NPlusOneDetectorInterface

    def record_query(sql : String) : Void
    end

    def start_relation_loading(relation_name : String, parent_model : String) : Void
    end

    def end_relation_loading : Void
    end

    def patterns : Array(NPlusOnePattern)
      [] of NPlusOnePattern
    end

    def issues : Array(Issue)
      [] of Issue
    end

    def clear : Void
    end
  end

  class Monitor
    # Non-nil accessors that return null objects if profiler/detector are nil
    def query_profiler! : QueryProfilerInterface
      @profiler || NullQueryProfiler.new
    end

    def n_plus_one_detector! : NPlusOneDetectorInterface
      @detector || NullNPlusOneDetector.new
    end
  end
end
