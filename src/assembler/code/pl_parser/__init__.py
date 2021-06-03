import re

import constants

class Parser():
    
    def parseSentence(self, str) :
        # Remove comments
        str = re.sub(constants.COMMENT_REGEX, '', str);

        # Segment the sentence
        segments = re.findall(constants.SEGMENT_REGEX, str);

        return segments