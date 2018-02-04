def truncate_str(string, length):
    return (string[:length] + '...') if (len(string) > length) \
        else string
