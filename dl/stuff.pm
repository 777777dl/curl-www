# Hj�lpfunktioner f�r formul�rinmatningar.

require "CGI.pm";
require "pbase.pm";
require "../curl.pm";

$databasefilename = "data/databas.db";

sub lheader {
    my ($title)=@_;

    if ($title eq "") {
        $title="curl packages";
    }

    open(FILE, "<../Makefile");
    while(<FILE>) {
        if($_ =~ /^STABLE= *(.*)/) {
            $stable=$1;
        }
    }
    close(FILE);

    # valid login-user, continue
    print <<MOO
Content-Type: text/html

<html><head><title>cURL: $title</title>
<link rel="stylesheet" type="text/css" href="/curl.css" />
</head>
<body><table><tr valign="top">
<td class="menu">$menu</td>
<td>
MOO
;
    print "<a href=\"list_entry.cgi\">list entries</a>\n",
    "<a href=\"mod_entry.cgi\">add entry</a>\n",
    "<a href=\"/download.html\">download page</a>",
    "<div class=\"pagetitle\">$title</div>";
}

sub lfooter {
    print <<FOOT
</td></tr></table>
</body></html>
FOOT
;
}


sub inputstuff::save_input 
{
    my %data=(@_);
    $data{"modify_time"}=time();       # stundens sekund

    if (CGI::param("action") eq "Save") {
        if ($id ne "") {
            my $ref=$db->get("id"=>$id);
            if ($$ref{"modify_time"} != CGI::param("modify_time")) {
                $warning_message="Dina �ndringar �r inte sparade. N�gon har ".
                    "�ndrat inneh�llet f�re dig (se nya inf�rda v�rden).";
            } else {
                $db->change("id", $id, %data);
                if ($db->save() == -1) {
                    $warning_message="Failed while saving database!";
                } else {
                    $result_message="Added entry";
                }
            }
        } else {
            my $newid=$db->add(%data);
            if ($db->save() == -1) {
                $warning_message="Failed saving database!";
            } else {
                $result_message="Added entry";
            }
        }
    } elsif (CGI::param("action") eq "Remove") {
        if (CGI::param("remove_check") != 1) {
            $warning_message="Ej raderat! Av s�kerhetssk�l m�ste du markera ".
                "kryssboxen bredvid f�r att kunna radera.";
        } elsif ($id ne "") {
            my $ref=$db->get("id"=>$id);
            if ($$ref{"modify_time"} != CGI::param("modify_time")) {
                $warning_message="Radering ej genomf�rd. N�gon har ".
                    "�ndrat inneh�llet under tiden (se nya inf�rda v�rden).";
            } elsif (!$db->delete("id", $id)) {
                if ($db->save() == -1) {
                    $warning_message="Failed to save database!";
                } else {
                    $result_message="Entry removed!";
                    # Log data
                }
                $id="";
            } else {
                $warning_message="Couldn't remove the entry!";
            }
        }
    }
    else {
        $warning_message = "strange action received: ".CGI::param("action");
    }
}

############
# Skriv ut informationstext
sub inputstuff::show_extra_messages 
{
    if ($warning_message ne "") {
        print "<p class=\"alert\">$warning_message</p>\n";
    }
    if ($result_message ne "") {
        print "<p class=\"info\">$result_message</p>\n";
    }
}



#### Formul�rfot
sub inputstuff::form_footer()
{
    print "<input type=submit name=\"action\" value=\"Save\"><br>\n";
        
    if ($id ne "") {
        print "<input type=submit name=\"action\" value=\"Remove\">";
        print "&nbsp;confirm:<input type=checkbox ";
        print "name=\"remove_check\" value=1><br>\n";
    }
    
    print "</form>\n";
    if($id ne "") {
        print "<form action=\"$cgi\" method=post>\n";
        print "<input type=submit name=\"action\" value=\"Erase form\">";
        print "</form><br>\n";
    }
################Slut p� formul�r
}

1;
