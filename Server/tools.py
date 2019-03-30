from time import gmtime, strftime, time

def isFloat(strings):
    try:
        for string in strings:
            float(string)
        return True
    except:
        return False

def nonNegativeFloat(strings):
    try:
        for string in strings:
            if float(string) < 0.0:
                return False
        return True
    except:
        return False

def hasInvalidCharacters(string):
    if set('[~!@#$%^& =*()_+{}":;]+$\\\'').intersection(string):
        print("string %s has invalid characters." % (string))
        return True
    return False



def getDateTime():
    return strftime("%Y-%m-%d %H:%M:%S", gmtime())

def timestampXMinutesAgo(minutes):
    return time() - minutes * 60





