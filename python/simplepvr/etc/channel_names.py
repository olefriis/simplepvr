import sys

def main(argv=None):
	import sqlite3, os; 
	con = sqlite3.connect(argv[1]); 
	cur = con.cursor(); 

	cur.execute('select * from channels WHERE hidden = 0 ORDER BY name'); 

	channels = cur.fetchall(); 

	for channel_row in channels:
		print channel_row[1]

	return 0

if __name__ == "__main__":
    sys.exit(main(sys.argv))
