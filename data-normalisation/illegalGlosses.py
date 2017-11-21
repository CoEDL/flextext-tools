#!/usr/bin/env python
"""
This script finds illegal glosses in flextext files.
It currently finds the following structures that are illegal in Murrinhpatha:
1) Two CSPs before a Cov
[tests still to be added -
2) Main CSP and serial CSP do not agree for person or tense]

Originally by Sasha Wilmoth (Appen), with modifications by John Mansfield (UniMelb).
"""

import sys
import codecs
import os
try:
	import xml.etree.cElementTree as ET
except ImportError:
	import xml.etree.ElementTree as ET
from argparse import ArgumentParser

def main():
	parser = ArgumentParser(description = __doc__)
	parser.add_argument('textdir', help = 'Directory with Flextexts')
	opts = parser.parse_args()

	illegalGlosses = 0
	totalfileCount = 0
	fileCount = 0

	print 'File\tPhrase No.\tType\tWord\tGloss'

	for root, dirs, files in os.walk(opts.textdir, topdown=False):
		for name in files:
			fullpath = os.path.join(root,name)
			if name.endswith(".flextext"):
				phraseNumber =0
				totalfileCount += 1
				illegalGlossFound = False
				tree = ET.parse(open(fullpath, 'r'))
				textroot = tree.getroot()

				for phraseelement in textroot.iter('phrase'):
					phraseNumber += 1
					for wordelement in phraseelement.iter('word'):
						illegalcsp = False
						doublecsp = False
						cspcount = 0
						msalist= []
						glslist= []
						word = wordelement[0].text # The word form is stored as the first subelement of the word element
						for morphelement in wordelement.iter('morph'):
							txt = ""
							cf = ""
							gls = ""
							msa = ""
							for itemelement in morphelement:
								if itemelement.attrib["type"] == "msa":
									if itemelement.text:
										msa = itemelement.text
									msalist.append(msa)
									if "Cov" in msa:
										if doublecsp:
											illegalcsp = True
									if "CSP" in msa:
										cspcount += 1
										# Test 1: Are there two CSPs before the coverb?
										if cspcount > 1:
											doublecsp = True # Now we need to look out for if we see a coverb
								if itemelement.attrib["type"] == "gls":
									if itemelement.text:
										gls = itemelement.text
									glslist.append(gls)
						# Report test failures
						if illegalcsp:
							illegalGlosses +=1
							print '\t'.join([fullpath,str(phraseNumber),"CSP_morphotactic",word.encode("utf-8"),' '.join(glslist).encode("utf-8")])
	print
	if not illegalGlosses:
		print 'No illegal glosses found in %s files' %(totalfileCount)
	elif illegalGlosses == 1:
		print '1 illegal gloss found in %s files' %(totalfileCount)
	elif illegalGlosses >= 1:
		print '%s illegal glosses found in %s files (out of %s files in total)' %(illegalGlosses,fileCount,totalfileCount)


if __name__=="__main__":
	main()
