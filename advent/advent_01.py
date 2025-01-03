# Done in 2 minutes...

def get_input() -> tuple[list[int], list[int]]:
    with open('advent_01.txt', 'r') as f:
        lines = f.readlines()
        to_int_pairs = lambda line: tuple(map(int, line.split()))
        lines_zipped = map(to_int_pairs, lines)
        return zip(*lines_zipped)


def get_total_distance(left_list: list[int], right_list: list[int]) -> int:
    sorted_values = zip(sorted(left_list), sorted(right_list))
    get_distance = lambda tuple: abs(tuple[0]-tuple[1])
    return sum(map(get_distance, sorted_values))


def main():
    left_list, right_list = get_input()
    print(f"Total distance is: {get_total_distance(left_list, right_list)}")


if __name__ == "__main__":
    main()