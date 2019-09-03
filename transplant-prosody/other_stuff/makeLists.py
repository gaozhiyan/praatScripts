import os
import random


def getFileNames():
    """Gets stimuli names."""
    path = "/Users/tim/Dropbox/Perception_Study/Pilot/pilot_stimuli"
    stim = []
    for i in os.listdir(path):
        if i[-4:] == ".wav":
            stim.append(i)
    return stim


def checkConstraint(item, prev_items):
    """Checks whether item abides by constraint."""
    min_distance = 5
    item_list = item.split("-")
    item_id = item_list[0][:]
    item_id_length = len(item_id)
    prev_items_count = len(prev_items)
    counter = 0
    for i in prev_items:
        counter += 1
        if counter > prev_items_count - min_distance:
            if i[:item_id_length] == item_id:
                lgl = False
                return lgl
    lgl = True
    return lgl


def makeList():
    """Makes list of stimuli."""
    stimuli = getFileNames()
    new_list = []
    while len(stimuli) != 0:
        legal = False
        for i in range(1000):
            candidate = random.choice(stimuli)
            legal = checkConstraint(candidate, new_list)
            if i == 999:
                makeList()
            if legal:
                new_list.append(candidate)
                stimuli.remove(candidate)
                break
            if not legal:
                continue
    return new_list


def saveList():
    """Saves list to .csv file."""
    f = open("stim_list_pilot.csv", "w")
    f.write("Trial,Filename\n")
    counter = 0
    for stimulus in experiment_list:
        counter += 1
        f.write(str(counter) + "," + stimulus + "\n")
    f.close()


experiment_list = makeList()
saveList()
