#!/usr/bin/python

import sys
import string


class PatternMatchingPaths:

    def __init__(self,lines):
        """Parse input into patterns and paths."""
        numPatterns = int(lines[0])
        self.patternStrings = lines[1:numPatterns + 1]
        # Sort patterns from best to worst so we can shortcut search when a match is found.
        self.patternStrings.sort(cmp=self.patternSortCmp, reverse=True)
        self.patternSplits = []
        for p in self.patternStrings:
            self.patternSplits.append(string.split(p,','))

        numPaths = int(lines[numPatterns + 1]) 
        self.pathStrings = lines[numPatterns + 2 : numPatterns + numPaths + 2]

    def printBestMatches(self):
        """
        Foreach path, search all patterns for the best match.
        Assumes that patternStrings is sorted from best to worst, 
        so we're done with a path once it matches its first pattern.
        """
        for path in self.pathStrings:
            # trim leading and trailing /'s and split path into its components:
            if '/' == path[0] :
                path = path[1:]
            if '/' == path[-1] :
                path = path[:-1]
            pathSplit = string.split(path,'/')
            
            currentBest = "NO MATCH"
            for i in range(len(self.patternStrings)):
                if self.matchPatternToPath(self.patternSplits[i], pathSplit):
                    currentBest = self.patternStrings[i]
                    # remember, we're assuming patternStrings (and patternSplits) are sorted best to worst:
                    break 
            print currentBest
        pass
    
    def patternSortCmp(self, x, y):
        """
        cmp function for sorting list of patterns.
        x and y are pattern strings.
        Returns positive if x>y (i.e. x is a better match), negative if x<y and 0 if x==y.
        Criteria: 
        1. The fewer wildcards, the better.
        2. The further left the first non-wildcard the better.

        There is no guidance on comparing patterns by number of elements.

        The best-matching pattern is the one which matches the path using the fewest wildcards.
        If there is a tie (that is, if two or more patterns with the same number
        of wildcards match a path), prefer the pattern whose leftmost wildcard
        appears in a field further to the right. If multiple patterns' leftmost
        wildcards appear in the same field position, apply this rule recursively
        to the remainder of the pattern.

        For example: given the patterns `*,*,c` and `*,b,*`, and the path
        `/a/b/c/`, the best-matching pattern would be `*,b,*`.
        """
        # Handle the NO MATCH case, if we ever use this elsewhere than initializing.
        if "NO MATCH" == x:
            if "NO MATCH" == y:
                return 0
            else:
                return -1
        if "NO MATCH" == y:
            if "NO MATCH" == x:
                return 0
            else:
                return 1

        xwc = ywc = 0
        for i in range(len(x)):
            if '*' == x[i]:
                xwc += 1
        for i in range(len(y)):
            if '*' == y[i]:
                ywc += 1
        if xwc == ywc:
            # First tiebreaker:
            xSplit = string.split(x,",")
            ySplit = string.split(y,",")
            if len(xSplit) < len(ySplit):
                minLen = len(xSplit)
            else:
                minLen = len(ySplit)
            for i in range(minLen):
                if '*' == xSplit[i]:
                    if '*' == ySplit[i]:
                        continue
                    else:
                        return -1
                else:
                    if '*' == ySplit[i]:
                        return 1
                    else:
                        continue
            # If first tiebreaker fails, return a tie:
            return 0
            # If you wanted to implement a second tiebreaker, such as 
            # "a greater number of elements is a better match,"
            # here would be the place to do it.
        else:
            if xwc>ywc: # x has more wildcards, x is worse, return a negative
                return -1
            else: # x has fewer wildcards, x is better, return a positive
                return 1 
        # unreached
        pass


    def matchPatternToPath(self, patternSplit, pathSplit):
        """
        Does the pattern match the path?
        patternSplit: the pattern string split into its components
        pathSplit:    the path    string split into its components
        """
        patternIndex = 0
        found = -1
        for pathIndex in range(len(pathSplit)):
            if ('*' == patternSplit[patternIndex]) or (pathSplit[pathIndex] == patternSplit[patternIndex]):
                if 0 == patternIndex:
                    found = pathIndex
                patternIndex +=1
                if patternIndex >= len(patternSplit):
                    return True
            else:
                patternIndex = 0
                if (found >= 0):
                    pathIndex = found
                found = -1
        return False

    def dump(self):
        for i in range(len(self.patternStrings)):
            print self.patternStrings[i]
            print self.patternSplits[i]
        print self.pathStrings


                
if "__main__" == __name__:            
    inputLines = []
    for line in sys.stdin:
        inputLines.append(line.rstrip())
    myPatMatchPath = PatternMatchingPaths(inputLines)
    myPatMatchPath.printBestMatches()
