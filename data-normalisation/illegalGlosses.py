#!/usr/bin/env python
"""
This script finds illegal glosses in flextext files.
It currently finds the following structures that are illegal in Murrinhpatha:
1) Two CSPs before a Cov

Originally by Sasha Wilmoth (Appen), with modifications by John Mansfield.
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

	for root, dirs, files in os.walk(opts.textdir, topdown=False):
		for name in files:
			fullpath = os.path.join(root,name)
			if name.endswith(".flextext"):
				phraseNumber =0
				totalfileCount += 1
				illegalGlossFound = False
				tree = ET.parse(open(fullpath, 'r'))
				textroot = tree.getroot()

				# Finding two morphs glossed with CSP before Cov
				for phraseelement in textroot.iter('phrase'):
					phraseNumber += 1
					for wordelement in phraseelement.iter('word'):
						covexists = False
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
									msa = itemelement.text
									msalist.append(msa)
									if "Cov" in msa:
										covexists = True
									if "CSP" in msa and not covexists:
										cspcount += 1
								if itemelement.attrib["type"] == "gls":
									gls = itemelement.text
									glslist.append(gls)
						if cspcount > 1:
							illegalGlossFound = True
							if illegalGlosses == 0:
								print 'File\tPhrase No.\t Word\tGloss'
							illegalGlosses +=1
							print '\t'.join([fullpath,str(phraseNumber),word,' '.join(glslist)])
	print
	if not illegalGlosses:
		print 'No illegal glosses found in %s files' %(totalfileCount)
	elif illegalGlosses == 1:
		print '1 illegal gloss found in %s files' %(totalfileCount)
	elif illegalGlosses >= 1:
		print '%s illegal glosses found in %s files (out of %s files in total)' %(illegalGlosses,fileCount,totalfileCount)


if __name__=="__main__":
	main()
