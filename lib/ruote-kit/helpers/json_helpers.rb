
# license is MIT, see LICENSE.txt

module RuoteKit
  module Helpers

    # Helpers for JSON rendering
    #
    module JsonHelpers

      def json(resource, *args)

        object = respond_to?("json_#{resource}") ?
          send("json_#{resource}", *args) : nil

        Rufus::Json.encode(
          'links' => links(resource), resource.to_s => object || args.first
        )
      end

      #def json_exception(code, exception)
      #  { 'code' => code, 'exception' => { 'message' => exception.message } }
      #end

      def json_processes

        @processes.map { |p| json_process(p) }
      end

      def json_process(process=@process)

        detailed = (@process != nil)

        process.as_h(detailed).merge('links' => [
          hlink('processes', process.wfid, :rel => 'self'),
          hlink('processes', process.wfid, :rel => '#process'),
          hlink('expressions', process.wfid, :rel => '#process_expressions'),
          hlink('workitems', process.wfid, :rel => '#process_workitems'),
          hlink('errors', process.wfid, :rel => '#process_errors'),
          hlink('schedules', process.wfid, :rel => '#process_schedules')
        ])
      end

      def json_expressions

        @process.expressions.map { |e| json_expression(e) }
      end

      def json_expression(expression=@expression)

        detailed = (@expression != nil)

        links = [
          hlink('expressions', expression.fei.sid, :rel => 'self'),
          hlink('processes', expression.fei.wfid, :rel => '#process'),
          hlink('expressions', expression.fei.wfid, :rel => '#process_expressions')
        ]
        links << hlink(
          'expressions', expression.parent.fei.sid, 'parent'
        ) if expression.parent

        expression.as_h(detailed).merge('links' => links)
      end

      def json_workitems

        @workitems.map { |w| json_workitem(w) }
      end

      def json_workitem(workitem=@workitem)

        detailed = (@workitem != nil)

        links = [
          hlink('workitems', workitem.fei.sid, :rel => 'self'),
          hlink('processes', workitem.fei.wfid, :rel => '#process'),
          hlink('expressions', workitem.fei.sid, :rel => '#expression'),
          hlink('expressions', workitem.fei.wfid, :rel => '#process_expressions'),
          hlink('errors', workitem.fei.wfid, :rel => '#process_errors')
        ]

        workitem.as_h(detailed).merge('links' => links)
      end

      def json_errors

        @errors.collect { |e| json_error(e) }
      end

      def json_error(error=@error)

        fei = error.fei
        wfid = fei.wfid

        error.to_h.merge('links' => [
          hlink('errors', fei.sid, :rel => 'self'),
          hlink('errors', wfid, :rel => '#process_errors'),
          hlink('processes', wfid, :rel => '#process')
        ])
      end

      def json_participants

        @participants.collect { |pa|
          pa.as_h.merge('links' => [ hlink('participants', :rel => 'self') ])
        }
      end

      def json_schedules

        @schedules.each do |sched|

          owner_fei = sched.delete('owner')
          target_fei = sched.delete('target')

          sched['owner'] = owner_fei.to_h
          sched['target'] = target_fei ? target_fei.to_h : nil

          sched['links'] = []

          sched['links'] << hlink(
            'expressions', owner_fei.sid, :rel => '#schedule_owner'
          )
          sched['links'] << hlink(
            'expressions', target_fei.sid, :rel => '#schedule_target'
          ) if target_fei
        end

        @schedules
      end

      def json_http_error(err)

        { 'code' => err[0], 'message' => err[1], 'cause' => err[2].to_s }
      end

      def links(resource)

        result = [
          hlink(:rel => '#root'),
          hlink('processes', :rel => '#processes'),
          hlink('workitems', :rel => '#workitems'),
          hlink('errors', :rel => '#errors'),
          hlink('participants', :rel => '#participants'),
          hlink('schedules', :rel => '#schedules'),
          hlink('history', :rel => '#history'),
          hlink(request.fullpath, :rel => 'self')
        ]

        if @skip # pagination is active

          result << hlink(resource.to_s, :rel => 'all')

          lim = @limit || settings.limit
          las = (@count / lim) * lim rescue 0
          pre = [ 0, @skip - lim ].max
          nex = [ @skip + lim, las ].min

          result << hlink(
            resource.to_s,
            :skip => 0, :limit => lim, :rel => 'first')
          result << hlink(
            resource.to_s,
            :skip => las, :limit => lim, :rel => 'last')
          result << hlink(
            resource.to_s,
            :skip => pre, :limit => lim, :rel => 'previous')
          result << hlink(
            resource.to_s,
            :skip => nex, :limit => lim, :rel => 'next')
        end

        result
      end
    end
  end
end

module Ruote

  #
  # Re-opening to provide an as_h method
  #
  class ProcessStatus

    def as_h(detailed=true)

      h = {}

      #h['expressions'] = @expressions.collect { |e| e.fei.to_h }
      #h['errors'] = @errors.collect { |e| e.to_h }

      h['type'] = 'process'
      h['detailed'] = detailed
      h['expressions'] = @expressions.size
      h['errors'] = @errors.size
      h['stored_workitems'] = @stored_workitems.size
      h['workitems'] = workitems.size

      h['root_expression_state'] = root_expression_state

      properties = %w[
        wfid
        definition_name definition_revision
        current_tree
        launched_time
        last_active
        tags
      ]

      properties += %w[
        original_tree
        variables
      ] if detailed

      properties.each { |m|
        h[m] = self.send(m)
      }

      h
    end

    def root_expression_state

      @root_expression ? @root_expression.state : '(no root expression)'
    end
  end

  #
  # Re-opening to provide an as_h method
  #
  class Workitem

    def as_h(detailed=true)

      r = {}

      r['id'] = fei.sid
      r['fei'] = fei.sid
      r['wfid'] = fei.wfid
      r['wf_name'] = wf_name
      r['wf_revision'] = wf_revision
      r['type'] = 'workitem'
      r['participant_name'] = participant_name

      r['fields'] = h.fields

      r['put_at'] = h.put_at

      r
    end
  end

  #
  # Re-opening to provide an as_h method
  #
  class ParticipantEntry

    def as_h(detailed=true)

      { 'regex' => @regex, 'classname' => @classname, 'options' => @options }
    end
  end

  module Exp

    #
    # Re-opening to provide an as_h method
    #
    class Exp::FlowExpression

      def as_h(detailed=true)

        r = {}

        r['fei'] = fei.sid
        r['parent'] = h.parent_id ? parent_id.sid : nil
        r['name'] = h.name
        r['class'] = self.class.name
        r['state'] = state

        if detailed
          r['variables'] = variables
          r['applied_workitem'] = h.applied_workitem['fields']
          r['tree'] = tree
          r['original_tree'] = original_tree
          r['timeout_schedule_id'] = h.timeout_schedule_id
        end

        r
      end
    end
  end
end

