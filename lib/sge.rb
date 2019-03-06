class SGE

  def initialize(options, base_name, config)
    @options   = options   # sge options
    @base_name = base_name
    @params    = load(config)
    @work      = File.join(ENV['PWD'], @params['work'])
    check_dir
  end
  attr_reader :command
  attr_accessor :params

  def check_dir
    Dir.mkdir(params['work'])    unless FileTest.exist? params['work']
    Dir.mkdir(params['results']) unless FileTest.exist? params['results']
  end

  def load(config)

    config = './config.yaml' unless FileTest.exist? config
    params = Hash.new
    File.open(config) do |io|
      YAML.load_documents(io) do |obj|
        obj.keys.each do |key|
          params = obj[key]
        end
      end
    end
    return params

  end

  def prepare(my_command)
    now = Time.now.strftime("%y%m%d_%H%M%S_%6N")
    working_dir = File.join(@work, @base_name)
    Dir.mkdir(working_dir) unless FileTest.exist? working_dir

    @std_file = File.join(working_dir, @base_name + ".#{now}.o.txt")
    @err_file = File.join(working_dir, @base_name + ".#{now}.e.txt")
    @sh_file  = File.join(working_dir, @base_name + ".#{now}.sh")

    @command =  @options + "\n"
    @command << "#\$ " + @params['process']['clusterOptions'] + "\n"
    @command << "#\$ -l nc=" + @params['process']['nc'].to_s + "\n"
    @command << '#$ -o ' + @std_file + "\n"
    @command << '#$ -e ' + @err_file + "\n\n"
    @command << my_command + "\n\n"

    sh_io = File.open(@sh_file, "w")
    sh_io.puts @command
    sh_io.close
  end

  def submit(queue = nil)
    cmd = ""
    if queue != nil
      cmd = "qsub -q #{queue} #{@sh_file}"
    else
      if @params['process']['queue'] != nil 
        cmd = "qsub -q #{@params['process']['queue']} #{@sh_file}"
      else
        cmd = "qsub #{@sh_file}"
      end
    end
    system(cmd)
  end
end

if __FILE__ == $0

  require "yaml"
  require "pp"

  # config for process 
  config = "config.yaml"

  # option for qsub
  options =  "#/bin/sh\n\n#! -O "
  options << "#MJS: -upc\n#MJS: -proc 1\n#MJS: -time 72:00:00"
  base_name = "hoge"

  # job
  command = "ls -la ./"

  # main
  sge = SGE.new(options, base_name, config)

  pp sge 
  pp sge.params
  pp sge.params['results']

  sge.prepare("ls -la ./")

  queue = "node.q"
  # sge.submit(queue)
end
