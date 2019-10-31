sudo adduser vm1 vboxsf

Expt 3: java installation

sudo -i
exit
//check proxy
sudo apt-get update
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get install openjdk-8-jre
sudo apt-get install openjdk-8-jdk
java -version

-----------------------------------

sudo apt-get install default-jdk

update-alternatives --default jdk
# set the environment variables- sudo nano ~/.bashrc
export JAVA_HOME
export CLASSPATH=$JAVA_HOME/lib
export PATH=$PATH:$JAVA_HOME/bin

java -cp . test.java

-------------------------------------

Expt 4: remote login

//set bridge adapter, allow all

sudo apt-get install openssh-server openssh-client
ssh-keygen -t rsa
cd ~/.ssh
chmod 700 id_rsa.pub
cp id_rsa.pub known_hosts
ssh-copy-id vm2@10.6.18.132
ssh vm2@10.6.18.132

-------------------------------------

Expt 5: File transfer

scp /home/vm1/Desktop/source.txt vm2@10.6.18.132:/home/vm2/Desktop/

-------------------------------------

Expt 6: Eucalyptus

euca-create-volume -U url -I accessKey -S secretKey --size 1 -Z clustername
euca-describe-volumes -U url -I accessKey -S secretKey

-------------------------------------

Expt 7: opennebula

wget -q -O- https://downloads.opennebula.org/repo/repo.key | sudo apt-key add -
sudo apt-get update
sudo apt install opennebula opennebula-sunstone opennebula-gate opennebula-flow
sudo /usr/share/one/install_gems


sudo rm /var/lib/apt/lists/lock
sudo rm /var/cache/apt/archives/lock
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/lib/dpkg/lock

sudo cat ~/.one/one_auth

sudo -i
su oneadmin
systemctl start opennebula opennebula-sunstone
oneuser show

localhost:9869

# KVM node controller
exit --> make sure u have to be in root@vm1
sudo apt-get install opennebula-node
sudo service libvirt-bin restart

sudo -i
su oneadmin

onehost list
onevnet list
oneimage list
onetemplate list

onehost create localhost -I kvm -v kvm -n dummy
cd /var/lib/one
ls -i
nano mynetwork.one
onevnet create mynetwork.one

oneimage create – name “centos6-5.4.0qcoq2c” --path “/home/geetika-vm1/Downloads/” --driver
qcow2 --datastore default


onetemplate create --name “Centos-6.5” --cpu 1 --vcpu 1 --memory 512 --arch x86_64 –disk “centos-6-
5.4.0.qcow2C” --nic “private” --vnc --ssh

#update SSH key
cat /var/lib/one/.ssh/id_rsa.pub

#instantiate vm
onevm list


ssh-keysan 192.168.1.14 192.168.1.14 >> /var/lib/one/.ssh/known_hosts

scp -rp /var/lib/one.ssh 192.168.1.15:/var/lib/one/

sudo nano /etc.hosts

and add 

127.0.0.1 vm1

-------------------------------------

Ex:9 Live migration

onevm list
onevm deploy 3 3. (vm->host)
onevm migrate 3 4 (host1->host2)

-------------------------------------

Expt 10: hadoop

sudo apt-get install default-jdk

sudo adduser hduser
sudo usermod -G sudo hduser
su hduser

ssh-keygen -t rsa -p '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa >> ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/id_rsa

ssh localhost
sudo apt-get install openssh-server openssh-client

sudo tar xfz hadoop_tar_file
sudo mv hadoop_2.7.7 /usr/local/hadoop

sudo nano /usr/local/hadoop/etc/hadoop/hadoop-env.sh
export JAVA_HOME="" (set path)

sudo nano ~/.bashrc
export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=$JAVA_HOME/lib

#HADOOP VARIABLES START
export HADOOP_INSTALL=/usr/local/hadoop
export PATH=$PATH:$HADOOP_INSTALL/bin
export PATH=$PATH:$HADOOP_INSTALL/sbin
export HADOOP_MAPRED_HOME=$HADOOP_INSTALL
export HADOOP_COMMON_HOME=$HADOOP_INSTALL
export HADOOP_HDFS_HOME=$HADOOP_INSTALL
export YARN_HOME=$HADOOP_INSTALL
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_INSTALL/lib/native export HADOOP_OPTS=“-Djava.library.path=$HADOOP_HOME/lib”
export HADOOP_CLASSPATH=$JAVA_HOME/lib/tools.jar
export HADOOP_HOME=/usr/local/hadoop
export PATH=$PATH:$HADOOP_HOME/bin
export PATH=$PATH:$HADOOP_HOME/sbin
#HADOOP VARIABLES END

source ~/.bashrc

sudo nano /usr/local/hadoop/etc/hadoop/core-site.xml
<property>
<name>fs.default.name</name>
<value>hdfs://localhost:9000</value>
</property>

sudo nano /usr/local/hadoop/etc/hadoop/yarn-site.xml
<property>
<name>yarn.nodemanager.aux-services</name>
<value>mapreduce_shuffle</value>
</property>

<property>
<name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
<value>org.apache.hadoop.mapred.Shufflehandler</value>
</property>

sudo cp mapred-site.xml.template mapred-site.xml
sudo nano /usr/local/hadoop/etc/hadoop/mapred-site.xml

<property>
<name>mapreduce.framework.name</name>
<value>yarn</yarn>
<property>

sudo mkdir -p /usr/local/hadoop_store/hdfs

sudo nano /usr/local/hadoop/etc/hadoop/hdfs-site.xml
<property>
<name>dfs.replication</name>
<value>1</value>
<property>

<property>
<name>dfs.namenode.name.dir</name>
<value>file:/usr/local/hadoop_store/hdfs/namenode</value>
<property>

<property>
<name>dfs.datanode.data.dir</name>
<value>file:/usr/local/hadoop_store/hdfs/datanode</value>
<property>

sudo chown hduser:hduser -R /usr/local/hadoop
sudo chown hduser:hduser -R /usr/local/hadoop_store
sudo chmod -R 777 /usr/local/hadoop
sudo chmod -R 777 /usr/local/hadoop_store

/usr/local/hadoop/bin/hadoop namenode -format

bash /usr/local/hadoop/sbin/start-all.sh
jps
localhost:8088

sudo nano input.txt

hdfs dfs -mkdir -p /user/hadoop/inputfiles
hdfs dfs -put input.txt /user/hadoop/inputfiles
hdfs dfs -ls input.txt /user/hadoop/inputfiles

--------------
#WordCount.java

import java.io.IOException;
import java.util.StringTokenizer;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class WordCount {

  public static class TokenizerMapper
       extends Mapper<Object, Text, Text, IntWritable>{

    private final static IntWritable one = new IntWritable(1);
    private Text word = new Text();

    public void map(Object key, Text value, Context context
                    ) throws IOException, InterruptedException {
      StringTokenizer itr = new StringTokenizer(value.toString());
      while (itr.hasMoreTokens()) {
        word.set(itr.nextToken());
        context.write(word, one);
      }
    }
  }

  public static class IntSumReducer
       extends Reducer<Text,IntWritable,Text,IntWritable> {
    private IntWritable result = new IntWritable();

    public void reduce(Text key, Iterable<IntWritable> values,
                       Context context
                       ) throws IOException, InterruptedException {
      int sum = 0;
      for (IntWritable val : values) {
        sum += val.get();
      }
      result.set(sum);
      context.write(key, result);
    }
  }

  public static void main(String[] args) throws Exception {
    Configuration conf = new Configuration();
    Job job = Job.getInstance(conf, "word count");
    job.setJarByClass(WordCount.class);
    job.setMapperClass(TokenizerMapper.class);
    job.setCombinerClass(IntSumReducer.class);
    job.setReducerClass(IntSumReducer.class);
    job.setOutputKeyClass(Text.class);
    job.setOutputValueClass(IntWritable.class);
    FileInputFormat.addInputPath(job, new Path(args[0]));
    FileOutputFormat.setOutputPath(job, new Path(args[1]));
    System.exit(job.waitForCompletion(true) ? 0 : 1);
  }
}

--------------

/usr/local/hadoop/bin/hadoop com.sun.tools.javac.Main WordCount.java
jar cf wc.jar WordCount*.class
ls
/usr/local/hadoop/bin/hadoop jar wc.jar WordCount /user/hadoop/inputfiles /user/hadoop/outputfiles

----------------------------------
Ex:11 hadoop fuse

wget https://archive.cloudera.com/cdh5/one-click-install/trusty/amd64/cdh5-repository_1.0_all.deb
sudo dpkg -i cdh5-repository_1.0_all.deb
sudo apt-get update 
sudo apt-get install hadoop-hdfs-fuse
sudo mkdir -p /mnt/hdfs
hadoop-fuse-dfs dfs://localhost:50070 /mnt/hdfs
