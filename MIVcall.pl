use strict;
use Getopt::Long;

use constant LF => "\n";
use constant {
    OPT_NO  => 0,
    OPT_YES => 1,
};

my $script_name = $0;
my @script_name_l = split("/", $script_name);
pop(@script_name_l);
my $SRC = join("/", @script_name_l);

if(length($SRC) == 0){$SRC = "."}

my ($CANCER_BAM, $BLOOD_BAM, $OUTPUT_FILE, $RMSK, $Region_file, $bwa_ref, $config_file, $help) = ("", "", "", "","", "-", "", "");

GetOptions(
        "BAM=s" => \$BLOOD_BAM,
	"OUTPUT_F=s" => \$OUTPUT_FILE,
        "MS=s" => \$RMSK,
        "MS2=s" => \$Region_file,
        "REF=s" => \$bwa_ref,
        "CONF=s" => \$config_file,
#        "h" => \$help
        "help" => \$help
);

my $message = << '&EOT&';
Usage: perl <path>/RUN_GIM_CALLER.pl [-BAM <input file (bam)>] [-OUT <output directory>] [-MS <MS location file>] [-MS2 <MS location file2>] [-REF <Reference file (fasta)>] [-CONF <Config file (Optional)>] [-h]
-BAM  	Input normal bam file (Required)
-MS		MS location file (Required)
-MS2		MS location file2 (Required)
-OUTPUT_F	Output file (Required)
-CONF		Config file (Optional)
-REF    	Reference genome (Index file for samtools is required.) (Optional)
-help      	Print this message
&EOT&

if($help == OPT_YES){
        print STDERR $message.LF;
        exit(0);
}

if(! $config_file){
	$config_file = "$SRC"."/"."parm.conf";
}

if( ! -f $BLOOD_BAM){print"$BLOOD_BAM Normal bam file !!\n"; exit(0)}
if( ! $OUTPUT_FILE){print"$OUTPUT_FILE Outout file !!\n"; exit(0)}
if( ! -f $RMSK){print"$RMSK MS location file !!\n"; exit(0)}
if( ! -f $Region_file){print"$Region_file MS location file !!\n"; exit(0)}
#if( ! -f $bwa_ref){print"$bwa_ref Reference file !!\n"; exit(0)}
if( ! -f $config_file){print"$config_file Config file !!\n"; exit(0)}

#####################GET PRMS###############################
my ($cancer, $normal, $call) = (0, 0, 0);
my %normal_prms = {};
my %call_prms = {};
open CONF, "$config_file" or die "Can not open $config_file !";
while(<CONF>){
	chomp;
	if($_ =~ /^#/ and $_ =~ /READ/){$normal = 1; $call = 0;}
	if($_ =~ /^#/ and $_ =~ /CALL/){$normal = 0; $call = 1;}
	
	if ($_ !~ /=/){next;}

	my @l = split(/=/, $_);
	my $parm_name = $l[0];
	my $parm_val = $l[1];
	$parm_name =~ s/ //g;
	$parm_val =~ s/ //g;
	
	if($normal){$normal_prms{$parm_name} = $parm_val}
	if($call){$call_prms{$parm_name} = $parm_val}
}
############################################################

####################MAKE CMD################################
#my %normal_option = ("REF" => $bwa_ref, "MQ" => $normal_prms{mq_cutoff}, "LL" => $normal_prms{len_cutoff1}, "ML" => $normal_prms{len_cutoff2}, "FL" => $normal_prms{flanking_len_cutoff}, "SL" => $normal_prms{S_length_cutoff}, "BQ" => $normal_prms{q_score_cutoff}, "SW" => $normal_prms{SW_alignment}, "GO" => $normal_prms{d}, "GE" => $normal_prms{e}, "MS" => $RMSK, "I" => $BLOOD_BAM);
my %normal_option = ("REF" => $bwa_ref, "MQ" => $normal_prms{mq_cutoff}, "LL" => $normal_prms{len_cutoff1}, "ML" => $normal_prms{len_cutoff2}, "FL" => $normal_prms{flanking_len_cutoff}, "SL" => $normal_prms{S_length_cutoff}, "BQ" => $normal_prms{q_score_cutoff}, "SW" => $normal_prms{SW_alignment}, "GO" => $normal_prms{d}, "GE" => $normal_prms{e}, "MS" => $RMSK, "I" => "$OUTPUT_FILE".".sam2");

my $BC_merge_file = "$SRC"."/merged.txt";

my %call_option = ("D" => $call_prms{BLOOD_MIN_DEPTH}, "L" => $call_prms{BLOOD_L}, "ER" => "$SRC/$call_prms{ERROR_RATE_TABLE}", "N" => "$call_prms{NUM}", "VAF" => "$call_prms{VAF}");

my @option = ();
for my $name (keys %normal_option){
        my $tmp = "-"."$name"." "."$normal_option{$name}";
        push(@option, $tmp);
}
my $normal_option_str = join(" ", @option);

my @option = ();
for my $name (keys %call_option){
        my $tmp = "-"."$name"." "."$call_option{$name}";
        push(@option, $tmp);
}
my $call_option_str = join(" ", @option);
my $GET_READS_FROM_NORMAL_REGION = "samtools view -F 1024 -F 0x400 --region-file $Region_file $BLOOD_BAM > $OUTPUT_FILE.sam";
my $READ_SELECTION_NORMAL = "python $SRC/bin/assign_reads.all_chr.py $RMSK $OUTPUT_FILE.sam > $OUTPUT_FILE.sam2";
my $GET_READS_FROM_NORMAL = "perl $SRC/bin/GET_READ.BLOOD.selected_reads.pl $normal_option_str > $OUTPUT_FILE.NUMBER";
#my $GET_READS_FROM_NORMAL = "perl $SRC/bin/GET_READ.BLOOD.pl $normal_option_str > $OUTPUT_FILE.NUMBER";
my $CALL = "perl $SRC/bin/GIM_CALLER.pl -I $OUTPUT_FILE.NUMBER $call_option_str > $OUTPUT_FILE";

############################################################

####################RUN#####################################
print"GET_READS_FROM_NORMAL_REGION\n";
print"$GET_READS_FROM_NORMAL_REGION\n";
system("$GET_READS_FROM_NORMAL_REGION");

print"READ_SELECTION_NORMAL";
print"$READ_SELECTION_NORMAL\n";
system("$READ_SELECTION_NORMAL");

print"GET_READS_FROM_NORMAL\n";
print"$GET_READS_FROM_NORMAL\n";
system("$GET_READS_FROM_NORMAL");

print"GIM CALL\n";
print"$CALL\n";
system("$CALL");

#unlink $OUTPUT_FILE.NUMBER;
print"OUTPUT; $OUTPUT_FILE\n";
############################################################
